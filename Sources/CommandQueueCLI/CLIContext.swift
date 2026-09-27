import ArgumentParser
import CommandQueueKit
import Foundation

/// Everything a command takes from the outside world. The live value is the only place the CLI reads
/// `ProcessInfo`; tests pass their own.
package struct CLIContext: Sendable {
    /// Where the command writes.
    package var output: CLIOutput
    /// The process environment.
    package var environment: [String: String]
    /// Kit use-case runner available to execute a queued command.
    package var commandQueueRunner: CommandQueueRunner?
    /// Kit use-case runner available to manage direct-only rules.
    package var commandQueueRuleRunner: CommandQueueRuleRunner?

    /// The real process output and environment.
    package static var live: CLIContext {
        let environment = ProcessInfo.processInfo.environment
        let configurationStore = JSONCommandQueueConfigurationStore()
        let runner = CommandQueueRunner(
            configurationLoader: configurationStore,
            locking: PosixCommandQueueLocking(),
            commandExecutor: PosixQueuedCommandExecutor()
        )
        return CLIContext(
            output: .live,
            environment: environment,
            commandQueueRunner: runner,
            commandQueueRuleRunner: CommandQueueRuleRunner(persistence: configurationStore)
        )
    }

    package init(
        output: CLIOutput,
        environment: [String: String],
        commandQueueRunner: CommandQueueRunner? = nil,
        commandQueueRuleRunner: CommandQueueRuleRunner? = nil
    ) {
        self.output = output
        self.environment = environment
        self.commandQueueRunner = commandQueueRunner
        self.commandQueueRuleRunner = commandQueueRuleRunner
    }

    /// Prints a command failure and maps it to the corresponding process status.
    package func failureExitCode(for error: any Error) -> ExitCode {
        output.standardError("cq: \(error)")

        return switch error {
        case let error as CommandQueueError:
            ExitCode(error.exitStatus)
        case let error as CommandQueueRuntimeError:
            ExitCode(error.exitStatus)
        default:
            ExitCode(70)
        }
    }

    /// Creates rule-management input using this invocation's environment.
    package func ruleRequest(configPath: String?) -> CommandQueueRuleRequest {
        CommandQueueRuleRequest(configPath: configPath, environment: environment)
    }
}
