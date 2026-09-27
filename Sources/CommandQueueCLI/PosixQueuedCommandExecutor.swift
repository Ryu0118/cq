import CommandQueueKit
import Darwin
import Foundation

/// Starts a child process and waits while the parent retains the queue lock.
package struct PosixQueuedCommandExecutor: QueuedCommandExecuting {
    /// Creates the POSIX process adapter.
    package init() {}

    /// Spawns argv directly without a shell and returns the child's shell status.
    package func run(
        command: [String],
        environment: [String: String],
        lockLease: any CommandQueueLockLease
    ) throws -> Int32 {
        guard let executable = command.first else {
            throw CommandQueueError.emptyCommand
        }

        let executablePath = try resolveExecutable(executable, environment: environment)
        let argumentPointers = try allocateCStringPointers(command, label: "argument")
        defer { argumentPointers.forEach { free($0) } }
        var argumentVector = argumentPointers.map(Optional.some)
        argumentVector.append(nil)

        var childEnvironment = environment
        childEnvironment[CommandQueueRuntimeSettings.queueLockMarker] = "1"
        let environmentEntries = childEnvironment.keys.sorted().compactMap { key -> String? in
            guard let value = childEnvironment[key] else { return nil }
            return "\(key)=\(value)"
        }
        let environmentPointers = try allocateCStringPointers(environmentEntries, label: "environment")
        defer { environmentPointers.forEach { free($0) } }
        var environmentVector = environmentPointers.map(Optional.some)
        environmentVector.append(nil)

        var fileActions: posix_spawn_file_actions_t?
        let initializationStatus = posix_spawn_file_actions_init(&fileActions)
        guard initializationStatus == 0 else {
            throw processSpawnError(command: command, code: initializationStatus)
        }
        defer { posix_spawn_file_actions_destroy(&fileActions) }

        let closeStatus = posix_spawn_file_actions_addclose(&fileActions, lockLease.fileDescriptor)
        guard closeStatus == 0 else {
            throw processSpawnError(command: command, code: closeStatus)
        }

        var childProcessID: pid_t = 0
        let spawnStatus = executablePath.withCString {
            posix_spawn(&childProcessID, $0, &fileActions, nil, &argumentVector, &environmentVector)
        }
        guard spawnStatus == 0 else {
            throw processSpawnError(command: command, code: spawnStatus)
        }

        return try waitForChild(childProcessID, command: command)
    }

    private func resolveExecutable(_ executable: String, environment: [String: String]) throws -> String {
        if executable.contains("/") {
            return try executablePath(executable, originalCommand: executable)
        }

        let searchPath = environment["PATH"] ?? "/usr/bin:/bin"
        var deniedPath: String?

        for component in searchPath.split(separator: ":", omittingEmptySubsequences: false) {
            let directory = component.isEmpty ? "." : String(component)
            let candidate = URL(filePath: directory, directoryHint: .isDirectory)
                .appending(path: executable)
                .path
            if access(candidate, X_OK) == 0 {
                return candidate
            }
            if errno == EACCES {
                deniedPath = candidate
            }
        }

        if let deniedPath {
            throw CommandQueueRuntimeError.commandNotExecutable(deniedPath)
        }
        throw CommandQueueRuntimeError.commandNotFound(executable)
    }

    private func executablePath(_ path: String, originalCommand: String) throws -> String {
        guard access(path, X_OK) == 0 else {
            if errno == EACCES {
                throw CommandQueueRuntimeError.commandNotExecutable(path)
            }
            throw CommandQueueRuntimeError.commandNotFound(originalCommand)
        }
        return path
    }

    private func allocateCStringPointers(_ values: [String], label: String) throws -> [UnsafeMutablePointer<CChar>] {
        var pointers: [UnsafeMutablePointer<CChar>] = []
        pointers.reserveCapacity(values.count)

        for value in values {
            guard let pointer = value.withCString({ strdup($0) }) else {
                pointers.forEach { free($0) }
                throw CommandQueueRuntimeError.processSpawnFailed(
                    command: label,
                    reason: "could not allocate a C string"
                )
            }
            pointers.append(pointer)
        }

        return pointers
    }

    private func processSpawnError(command: [String], code: Int32) -> CommandQueueRuntimeError {
        let commandLine = command.joined(separator: " ")
        return .processSpawnFailed(command: commandLine, reason: String(cString: strerror(code)))
    }

    private func waitForChild(_ childProcessID: pid_t, command: [String]) throws -> Int32 {
        var status: Int32 = 0

        while true {
            let waitedProcessID = waitpid(childProcessID, &status, 0)
            if waitedProcessID == childProcessID {
                break
            }
            if waitedProcessID == -1, errno == EINTR {
                continue
            }

            let commandLine = command.joined(separator: " ")
            throw CommandQueueRuntimeError.processWaitFailed(
                command: commandLine,
                reason: String(cString: strerror(errno))
            )
        }

        let terminatingSignal = status & 0x7F
        guard terminatingSignal != 0 else {
            return (status >> 8) & 0xFF
        }
        return 128 + terminatingSignal
    }
}
