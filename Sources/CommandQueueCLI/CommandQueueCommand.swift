import ArgumentParser
import CommandQueueKit

/// The root command of the `CommandQueue` executable.
package struct CommandQueueCommand: ContextualCommand {
    /// Command name, help text, and the `--version` value.
    package static let configuration = CommandConfiguration(
        commandName: "cq",
        abstract: "Serialize a local command across command-queue processes.",
        version: CommandQueueVersion.current
    )

    /// Optional path to a JSON command policy file.
    @Option(name: .long, help: "Path to the command-queue JSON configuration.")
    package var configPath: String?

    /// Executable and arguments after the `--` separator.
    @Argument(parsing: .captureForPassthrough, help: "Command and arguments to execute.")
    package var command: [String] = []

    package init() {}

    /// Preserves the no-argument greeting or delegates one request to the Kit runner.
    package func run(context: CLIContext) async throws {
        guard !command.isEmpty else {
            context.output.standardOutput(CommandQueueKit.greeting())
            return
        }

        guard let runner = context.commandQueueRunner else {
            let error = CommandQueueRuntimeError.runnerUnavailable
            context.output.standardError("cq: \(error)")
            throw ExitCode(error.exitStatus)
        }

        do {
            let childStatus = try runner.run(
                CommandQueueRequest(
                    command: command,
                    configPath: configPath,
                    environment: context.environment
                )
            )
            if childStatus != 0 {
                throw ExitCode(childStatus)
            }
        } catch let error as ExitCode {
            throw error
        } catch let error as CommandQueueError {
            context.output.standardError("cq: \(error)")
            throw ExitCode(error.exitStatus)
        } catch let error as CommandQueueRuntimeError {
            context.output.standardError("cq: \(error)")
            throw ExitCode(error.exitStatus)
        } catch {
            context.output.standardError("cq: \(error.localizedDescription)")
            throw ExitCode(70)
        }
    }
}
