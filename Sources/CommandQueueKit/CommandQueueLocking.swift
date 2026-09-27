/// Acquires an exclusive lock shared by independent command-queue processes.
package protocol CommandQueueLocking: Sendable {
    /// Blocks until the path's exclusive lock is held.
    func acquire(at path: String) throws -> any CommandQueueLockLease
}
