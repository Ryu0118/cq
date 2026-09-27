/// Runs one queued-command use case from policy validation through lock release.
package struct CommandQueueRunner: Sendable {
    private let configurationLoader: any CommandQueueConfigurationLoading
    private let locking: any CommandQueueLocking
    private let commandExecutor: any QueuedCommandExecuting

    /// Environment marker set on children to prevent recursive queue acquisition.
    package static let queueLockMarker = "CQ_INTERNAL_QUEUE_LOCK_HELD"

    /// Creates a runner with the configuration, lock, and process adapters.
    package init(
        configurationLoader: some CommandQueueConfigurationLoading,
        locking: some CommandQueueLocking,
        commandExecutor: some QueuedCommandExecuting
    ) {
        self.configurationLoader = configurationLoader
        self.locking = locking
        self.commandExecutor = commandExecutor
    }

    /// Loads policy, rejects nested or direct-only commands, and runs under the machine lock.
    package func run(_ request: CommandQueueRequest) throws -> Int32 {
        guard request.environment[Self.queueLockMarker] != "1" else {
            throw CommandQueueError.nestedQueueInvocation
        }

        let settings = try configurationLoader.load(
            configPath: request.configPath,
            environment: request.environment
        )
        let policy = DirectOnlyCommandPolicy(patterns: settings.configuration.directOnlyPatterns)
        try policy.validate(command: request.command)

        let lease = try locking.acquire(at: settings.lockFilePath)
        let childStatus: Int32
        do {
            childStatus = try commandExecutor.run(
                command: request.command,
                environment: request.environment,
                lockLease: lease
            )
        } catch {
            let executionError = error
            try lease.release()
            throw executionError
        }

        try lease.release()
        return childStatus
    }
}
