import ArgumentParser
import CommandQueueKit

/// Root command for help, version, and configuration subcommands.
package struct CommandQueueCommand: ContextualCommand {
    /// Command name, help text, subcommands, and the `--version` value.
    package static let configuration = CommandConfiguration(
        commandName: "cq",
        abstract: "Serialize local commands and manage direct-only rules.",
        discussion: "Use `cq <executable> [args...]` to run a command directly through the queue. The first word is passed to the child unless it matches a cq subcommand.",
        version: CommandQueueVersion.current,
        subcommands: [
            CommandQueueRunCommand.self,
            CommandQueueAddRuleCommand.self,
            CommandQueueListRulesCommand.self,
            CommandQueueRemoveRuleCommand.self,
        ]
    )

    package init() {}

    /// Preserves the greeting when no command or subcommand is supplied.
    package func run(context: CLIContext) async throws {
        context.output.standardOutput(CommandQueueKit.greeting())
    }
}
