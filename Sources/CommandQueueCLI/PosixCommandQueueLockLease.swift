import CommandQueueKit
import Darwin

/// Holds the open descriptor that owns an exclusive flock.
package struct PosixCommandQueueLockLease: CommandQueueLockLease {
    /// The descriptor closed in the spawned child process.
    package let fileDescriptor: Int32
    private let lockFilePath: String

    /// Creates a lease for an already acquired lock file descriptor.
    package init(fileDescriptor: Int32, lockFilePath: String) {
        self.fileDescriptor = fileDescriptor
        self.lockFilePath = lockFilePath
    }

    /// Closes the descriptor and releases the lock.
    package func release() throws {
        guard close(fileDescriptor) == 0 else {
            let reason = String(cString: strerror(errno))
            throw CommandQueueRuntimeError.lockOperationFailed(path: lockFilePath, reason: reason)
        }
    }
}
