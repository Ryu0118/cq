import ArgumentParser
import CommandQueueKit

/// Removes one exact direct-only command pattern from the user's configuration.
package struct CommandQueueRemoveRuleCommand: ContextualCommand {
    /// Canonical name used by the parser and entry point.
    package static let commandName = "remove-rule"

    /// Configuration for the remove-rule subcommand.
    package static let configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Remove an exact direct-only command pattern."
    )

    /// Optional configuration file override.
    @Option(name: .customLong("config"), help: ArgumentHelp("Path to the command-queue JSON configuration.", valueName: "path"))
    package var configPath: String?

    /// Exact regular expression previously added to the configuration.
    @Argument(help: "Exact regular expression to remove.")
    package var pattern: String

    package init() {}

    /// Removes the rule through the Kit runner.
    package func run(context: CLIContext) async throws {
        guard let runner = context.commandQueueRuleRunner else {
            throw context.failureExitCode(for: CommandQueueRuntimeError.runnerUnavailable)
        }

        do {
            try runner.remove(pattern, from: context.ruleRequest(configPath: configPath))
            context.output.standardOutput("Removed direct-only rule: \(pattern)")
        } catch {
            throw context.failureExitCode(for: error)
        }
    }
}
