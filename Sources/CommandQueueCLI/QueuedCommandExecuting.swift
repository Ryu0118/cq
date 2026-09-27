import CommandQueueKit

/// Starts a command while the parent process retains the queue lock.
package protocol QueuedCommandExecuting: Sendable {
    /// Runs the argv vector with inherited standard streams and environment.
    func run(
        command: [String],
        environment: [String: String],
        lockLease: any CommandQueueLockLease
    ) throws -> Int32
}
