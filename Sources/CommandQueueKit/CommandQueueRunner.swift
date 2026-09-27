/// Validates a command and acquires its serialization lock.
package struct CommandQueueRunner: Sendable {
    private let locking: any CommandQueueLocking

    /// Creates a runner with the platform's lock implementation.
    package init(locking: some CommandQueueLocking) {
        self.locking = locking
    }

    /// Checks direct-only policy before waiting for the exclusive lock.
    package func acquire(for request: CommandQueueRequest) throws -> any CommandQueueLockLease {
        let policy = DirectOnlyCommandPolicy(patterns: request.directOnlyPatterns)
        try policy.validate(command: request.command)
        return try locking.acquire(at: request.lockFilePath)
    }
}
