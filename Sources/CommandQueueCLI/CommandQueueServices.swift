import CommandQueueKit

/// Live adapters used by the command-line entry point.
package struct CommandQueueServices: Sendable {
    /// Applies policy and acquires the machine-local lock.
    package let runner: CommandQueueRunner
    /// Resolves configuration and lock storage.
    package let configurationLoader: any CommandQueueConfigurationLoading
    /// Starts and waits for the child command.
    package let commandExecutor: any QueuedCommandExecuting

    /// Creates the live CLI services.
    package init(
        runner: CommandQueueRunner,
        configurationLoader: some CommandQueueConfigurationLoading,
        commandExecutor: some QueuedCommandExecuting
    ) {
        self.runner = runner
        self.configurationLoader = configurationLoader
        self.commandExecutor = commandExecutor
    }
}
