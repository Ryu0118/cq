/// A held lock that keeps a command inside the serialized section.
package protocol CommandQueueLockLease: Sendable {
    /// File descriptor inherited by the spawn adapter and closed in the child.
    var fileDescriptor: Int32 { get }

    /// Releases the lock after the child command finishes.
    func release() throws
}
