import ArgumentParser
import CommandQueueKit

/// Lists the direct-only patterns in the user's configuration.
package struct CommandQueueListRulesCommand: ContextualCommand {
    /// Canonical name used by the parser and entry point.
    package static let commandName = "list-rules"
    /// Singular spelling accepted by the parser and entry point.
    package static let singularAlias = "list-rule"
    /// Singular spelling accepted for consistency with add-rule and remove-rule.
    package static let aliases = [singularAlias]

    /// Configuration for the list-rules subcommand.
    package static let configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "List configured direct-only command patterns.",
        aliases: aliases
    )

    /// Optional configuration file override.
    @Option(name: .customLong("config"), help: ArgumentHelp("Path to the command-queue JSON configuration.", valueName: "path"))
    package var configPath: String?

    package init() {}

    /// Lists the rules through the Kit runner.
    package func run(context: CLIContext) async throws {
        guard let runner = context.commandQueueRuleRunner else {
            throw context.failureExitCode(for: CommandQueueRuntimeError.runnerUnavailable)
        }

        do {
            let rules = try runner.list(context.ruleRequest(configPath: configPath))
            if rules.isEmpty {
                context.output.standardOutput("No direct-only rules configured.")
            } else {
                context.output.standardOutput(rules.map { "- \($0)" }.joined(separator: "\n"))
            }
        } catch {
            throw context.failureExitCode(for: error)
        }
    }
}
