import CommandQueueKit
import Darwin

/// Acquires an advisory lock shared by all cq processes on the machine.
package struct PosixCommandQueueLocking: CommandQueueLocking {
    /// Creates the POSIX lock adapter.
    package init() {}

    /// Opens a stable lock file and waits until its exclusive flock is available.
    package func acquire(at path: String) throws -> any CommandQueueLockLease {
        let fileDescriptor = try openSharedLockFile(at: path)

        while flock(fileDescriptor, LOCK_EX) == -1 {
            let errorCode = errno
            if errorCode == EINTR {
                continue
            }
            _ = close(fileDescriptor)
            throw CommandQueueRuntimeError.lockOperationFailed(
                path: path,
                reason: String(cString: strerror(errorCode))
            )
        }

        return PosixCommandQueueLockLease(fileDescriptor: fileDescriptor, lockFilePath: path)
    }

    private func openSharedLockFile(at path: String) throws -> Int32 {
        for attempt in 0 ..< 50 {
            let fileDescriptor = path.withCString {
                open($0, O_CREAT | O_RDONLY | O_NOFOLLOW | O_CLOEXEC, mode_t(0o444))
            }
            guard fileDescriptor >= 0 else {
                let errorCode = errno
                if errorCode == EACCES, attempt < 49 {
                    usleep(20000)
                    continue
                }
                throw lockOpenError(path: path, errorCode: errorCode)
            }

            var fileStatus = stat()
            guard fstat(fileDescriptor, &fileStatus) == 0 else {
                let errorCode = errno
                _ = close(fileDescriptor)
                throw lockOpenError(path: path, errorCode: errorCode)
            }
            guard fileStatus.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG) else {
                _ = close(fileDescriptor)
                throw CommandQueueRuntimeError.lockOpenFailed(
                    path: path,
                    reason: "the lock path is not a regular file"
                )
            }

            if fchmod(fileDescriptor, mode_t(0o444)) == -1 {
                let errorCode = errno
                var currentStatus = stat()
                let alreadyShared = fstat(fileDescriptor, &currentStatus) == 0
                    && currentStatus.st_mode & mode_t(0o444) == mode_t(0o444)
                guard errorCode == EPERM, alreadyShared else {
                    _ = close(fileDescriptor)
                    throw lockOpenError(path: path, errorCode: errorCode)
                }
            }

            return fileDescriptor
        }

        throw CommandQueueRuntimeError.lockOpenFailed(
            path: path,
            reason: "the shared lock file did not become readable by all users"
        )
    }

    private func lockOpenError(path: String, errorCode: Int32) -> CommandQueueRuntimeError {
        CommandQueueRuntimeError.lockOpenFailed(
            path: path,
            reason: String(cString: strerror(errorCode))
        )
    }
}
