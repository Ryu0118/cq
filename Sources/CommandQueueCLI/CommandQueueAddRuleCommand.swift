import ArgumentParser
import CommandQueueKit

/// Adds one direct-only command pattern to the user's configuration.
package struct CommandQueueAddRuleCommand: ContextualCommand {
    /// Canonical name used by the parser and entry point.
    package static let commandName = "add-rule"

    /// Configuration for the add-rule subcommand.
    package static let configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Add a command pattern that must run directly."
    )

    /// Optional configuration file override.
    @Option(name: .customLong("config"), help: ArgumentHelp("Path to the command-queue JSON configuration.", valueName: "path"))
    package var configPath: String?

    /// Regular expression matched against the executable and its arguments.
    @Argument(help: "Regular expression for the direct-only command.")
    package var pattern: String

    package init() {}

    /// Adds the rule through the Kit runner.
    package func run(context: CLIContext) async throws {
        guard let runner = context.commandQueueRuleRunner else {
            throw context.failureExitCode(for: CommandQueueRuntimeError.runnerUnavailable)
        }

        do {
            try runner.add(pattern, to: context.ruleRequest(configPath: configPath))
            context.output.standardOutput("Added direct-only rule: \(pattern)")
        } catch {
            throw context.failureExitCode(for: error)
        }
    }
}
