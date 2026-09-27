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

    /// The real process output and environment.
    package static var live: CLIContext {
        let environment = ProcessInfo.processInfo.environment
        let runner = CommandQueueRunner(
            configurationLoader: JSONCommandQueueConfigurationLoader(),
            locking: PosixCommandQueueLocking(),
            commandExecutor: PosixQueuedCommandExecutor()
        )
        return CLIContext(output: .live, environment: environment, commandQueueRunner: runner)
    }

    package init(
        output: CLIOutput,
        environment: [String: String],
        commandQueueRunner: CommandQueueRunner? = nil
    ) {
        self.output = output
        self.environment = environment
        self.commandQueueRunner = commandQueueRunner
    }
}
