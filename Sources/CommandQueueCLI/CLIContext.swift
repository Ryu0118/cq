import CommandQueueKit
import Foundation

/// Everything a command takes from the outside world. The live value is the only place the CLI reads
/// `ProcessInfo`; tests pass their own.
package struct CLIContext: Sendable {
    /// Where the command writes.
    package var output: CLIOutput
    /// The process environment.
    package var environment: [String: String]
    /// Services available to execute a queued child command.
    package var commandQueueServices: CommandQueueServices?

    /// The real process output and environment.
    package static var live: CLIContext {
        let environment = ProcessInfo.processInfo.environment
        let services = CommandQueueServices(
            runner: CommandQueueRunner(locking: PosixCommandQueueLocking()),
            configurationLoader: JSONCommandQueueConfigurationLoader(),
            commandExecutor: PosixQueuedCommandExecutor()
        )
        return CLIContext(output: .live, environment: environment, commandQueueServices: services)
    }

    package init(
        output: CLIOutput,
        environment: [String: String],
        commandQueueServices: CommandQueueServices? = nil
    ) {
        self.output = output
        self.environment = environment
        self.commandQueueServices = commandQueueServices
    }
}
