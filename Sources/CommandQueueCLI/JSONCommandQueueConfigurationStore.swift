import CommandQueueKit
import Foundation

/// Loads and persists the user's JSON policy using the process file system.
package struct JSONCommandQueueConfigurationStore: CommandQueueConfigurationLoading, CommandQueueDirectOnlyRulePersisting {
    /// Creates a store using the process file system.
    package init() {}

    /// Reads the optional policy and returns the shared machine lock path.
    package func load(
        configPath: String?,
        environment: [String: String]
    ) throws -> CommandQueueRuntimeSettings {
        let configURL = try configurationURL(configPath: configPath, environment: environment)
        let configuration = try loadConfiguration(at: configURL, wasExplicit: configPath != nil)

        return CommandQueueRuntimeSettings(
            configuration: configuration,
            lockFilePath: CommandQueueRuntimeSettings.machineLockFilePath
        )
    }

    /// Reads the current rules, treating a missing file as an empty configuration.
    package func loadRules(configPath: String?, environment: [String: String]) throws -> [String] {
        let configURL = try configurationURL(configPath: configPath, environment: environment)
        return try loadConfiguration(at: configURL, wasExplicit: false).directOnlyPatterns
    }

    /// Writes the current rules and creates the parent directory when needed.
    package func saveRules(_ rules: [String], configPath: String?, environment: [String: String]) throws {
        let configURL = try configurationURL(configPath: configPath, environment: environment)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(ConfigurationFile(directOnlyPatterns: rules))
            try FileManager.default.createDirectory(
                at: configURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: configURL, options: .atomic)
        } catch {
            throw CommandQueueRuntimeError.configurationWriteFailed(
                path: configURL.path,
                reason: error.localizedDescription
            )
        }
    }

    private func loadConfiguration(at url: URL, wasExplicit: Bool) throws -> CommandQueueConfiguration {
        guard FileManager.default.fileExists(atPath: url.path) else {
            if wasExplicit {
                throw CommandQueueRuntimeError.configurationNotFound(path: url.path)
            }
            return CommandQueueConfiguration()
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw CommandQueueRuntimeError.configurationReadFailed(
                path: url.path,
                reason: error.localizedDescription
            )
        }

        let file: ConfigurationFile
        do {
            file = try JSONDecoder().decode(ConfigurationFile.self, from: data)
        } catch {
            throw CommandQueueRuntimeError.configurationReadFailed(
                path: url.path,
                reason: error.localizedDescription
            )
        }

        return CommandQueueConfiguration(directOnlyPatterns: file.directOnlyPatterns)
    }

    private func configurationURL(configPath: String?, environment: [String: String]) throws -> URL {
        if let configPath {
            return URL(filePath: configPath)
        }

        let configRoot = try directoryRoot(
            override: nonempty(environment["XDG_CONFIG_HOME"]),
            home: nonempty(environment["HOME"]),
            homeSuffix: ".config"
        )
        return configRoot.appendingPathComponent("command-queue/config.json")
    }

    private func directoryRoot(override: String?, home: String?, homeSuffix: String) throws -> URL {
        if let override {
            return URL(filePath: override, directoryHint: .isDirectory)
        }
        guard let home else {
            throw CommandQueueRuntimeError.missingHomeDirectory
        }
        return URL(filePath: home, directoryHint: .isDirectory)
            .appendingPathComponent(homeSuffix, isDirectory: true)
    }

    private func nonempty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }

    private struct ConfigurationFile: Codable {
        let directOnlyPatterns: [String]

        private enum CodingKeys: String, CodingKey {
            case directOnlyPatterns
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            directOnlyPatterns = try container.decodeIfPresent([String].self, forKey: .directOnlyPatterns) ?? []
        }

        init(directOnlyPatterns: [String]) {
            self.directOnlyPatterns = directOnlyPatterns
        }
    }
}
