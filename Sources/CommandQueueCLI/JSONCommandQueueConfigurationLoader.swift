import CommandQueueKit
import Foundation

/// Loads the user's JSON policy and selects the shared machine lock location.
package struct JSONCommandQueueConfigurationLoader: CommandQueueConfigurationLoading {
    /// Creates a loader using the process file system.
    package init() {}

    /// Reads the optional policy and returns the shared machine lock path.
    package func load(
        configPath: String?,
        environment: [String: String]
    ) throws -> CommandQueueRuntimeSettings {
        let configURL: URL
        if let configPath {
            configURL = URL(filePath: configPath)
        } else {
            let configRoot = try directoryRoot(
                override: nonempty(environment["XDG_CONFIG_HOME"]),
                home: nonempty(environment["HOME"]),
                homeSuffix: ".config"
            )
            configURL = configRoot.appendingPathComponent("command-queue/config.json")
        }
        let configuration = try loadConfiguration(at: configURL, wasExplicit: configPath != nil)

        return CommandQueueRuntimeSettings(
            configuration: configuration,
            lockFilePath: CommandQueueRuntimeSettings.machineLockFilePath
        )
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

    private struct ConfigurationFile: Decodable {
        let directOnlyPatterns: [String]

        private enum CodingKeys: String, CodingKey {
            case directOnlyPatterns
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            directOnlyPatterns = try container.decodeIfPresent([String].self, forKey: .directOnlyPatterns) ?? []
        }
    }
}
