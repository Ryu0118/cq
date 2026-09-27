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

    /// Preserves the no-argument starter behavior or executes a queued command.
    package func run(context: CLIContext) async throws {
        guard !command.isEmpty else {
            context.output.standardOutput(CommandQueueKit.greeting())
            return
        }

        if context.environment[CommandQueueRuntimeSettings.queueLockMarker] == "1" {
            let error = CommandQueueRuntimeError.nestedQueueInvocation
            context.output.standardError("cq: \(error)")
            throw ExitCode(error.exitStatus)
        }

        guard let services = context.commandQueueServices else {
            let error = CommandQueueRuntimeError.servicesUnavailable
            context.output.standardError("cq: \(error)")
            throw ExitCode(error.exitStatus)
        }

        do {
            let settings = try services.configurationLoader.load(
                configPath: configPath,
                environment: context.environment
            )
            let request = CommandQueueRequest(
                command: command,
                lockFilePath: settings.lockFilePath,
                directOnlyPatterns: settings.configuration.directOnlyPatterns
            )
            let lease = try services.runner.acquire(for: request)

            var childStatus: Int32 = 0
            var executionError: (any Error)?
            do {
                childStatus = try services.commandExecutor.run(
                    command: command,
                    environment: context.environment,
                    lockLease: lease
                )
            } catch {
                executionError = error
            }
            try lease.release()

            if let executionError {
                throw executionError
            }
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
