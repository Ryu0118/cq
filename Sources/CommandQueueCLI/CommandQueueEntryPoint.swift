import ArgumentParser

/// Routes known cq subcommands to ArgumentParser and all other first words to the command proxy.
package enum CommandQueueEntryPoint {
    private static let rootCommands: Set<String> = [
        CommandQueueRunCommand.commandName,
        CommandQueueAddRuleCommand.commandName,
        CommandQueueListRulesCommand.commandName,
        CommandQueueListRulesCommand.singularAlias,
        CommandQueueRemoveRuleCommand.commandName,
        "-h",
        "--help",
        "--version",
        "--experimental-dump-help",
        "help",
    ]

    /// Starts cq with direct command passthrough as the default invocation.
    package static func main() async {
        let arguments = Array(CommandLine.arguments.dropFirst())
        if let first = arguments.first, !rootCommands.contains(first) {
            await CommandQueueRunCommand.main(arguments)
        } else {
            await CommandQueueCommand.main(arguments)
        }
    }
}
