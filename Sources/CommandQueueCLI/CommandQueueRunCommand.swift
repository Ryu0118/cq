import ArgumentParser
import CommandQueueKit

/// Executes an arbitrary command through the machine-local queue.
package struct CommandQueueRunCommand: ContextualCommand {
    /// Canonical name used by the parser and entry point.
    package static let commandName = "run"

    /// Configuration for the explicit run subcommand.
    package static let configuration = CommandConfiguration(
        commandName: commandName,
        abstract: "Run a command through the machine-local queue."
    )

    /// Optional path to a JSON command policy file.
    @Option(name: .customLong("config"), help: ArgumentHelp("Path to the command-queue JSON configuration.", valueName: "path"))
    package var configPath: String?

    /// Executable and its arguments.
    @Argument(parsing: .captureForPassthrough, help: "Command and arguments to execute.")
    package var command: [String] = []

    package init() {}

    /// Preserves the no-argument greeting or delegates one request to the Kit runner.
    package func run(context: CLIContext) async throws {
        let childCommand = command.first == "--" ? Array(command.dropFirst()) : command
        guard !childCommand.isEmpty else {
            context.output.standardOutput(CommandQueueKit.greeting())
            return
        }

        guard let runner = context.commandQueueRunner else {
            throw context.failureExitCode(for: CommandQueueRuntimeError.runnerUnavailable)
        }

        do {
            let childStatus = try runner.run(
                CommandQueueRequest(
                    command: childCommand,
                    configPath: configPath,
                    environment: context.environment
                )
            )
            if childStatus != 0 {
                throw ExitCode(childStatus)
            }
        } catch let error as ExitCode {
            throw error
        } catch {
            throw context.failureExitCode(for: error)
        }
    }
}
