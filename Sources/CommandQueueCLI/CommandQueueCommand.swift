import ArgumentParser
import CommandQueueKit

/// The root command of the `CommandQueue` executable.
package struct CommandQueueCommand: ContextualCommand {
    /// Command name, help text, and the `--version` value.
    package static let configuration = CommandConfiguration(
        commandName: "cq",
        abstract: "Machine-wide command queue command-line tool.",
        version: CommandQueueVersion.current
    )

    package init() {}

    /// Prints the starter greeting.
    package func run(context: CLIContext) async throws {
        context.output.standardOutput(CommandQueueKit.greeting())
    }
}
