/// A configuration or operating-system error reported by the CLI adapters.
package enum CommandQueueRuntimeError: Error, Equatable, Sendable, CustomStringConvertible {
    /// The user home directory is unavailable.
    case missingHomeDirectory
    /// An explicitly requested configuration file does not exist.
    case configurationNotFound(path: String)
    /// A configuration file could not be read or decoded.
    case configurationReadFailed(path: String, reason: String)
    /// The lock file could not be opened.
    case lockOpenFailed(path: String, reason: String)
    /// The process could not acquire or release the lock.
    case lockOperationFailed(path: String, reason: String)
    /// The executable could not be found in PATH.
    case commandNotFound(String)
    /// The executable exists but cannot be run.
    case commandNotExecutable(String)
    /// The child process could not be started.
    case processSpawnFailed(command: String, reason: String)
    /// The child process could not be waited for.
    case processWaitFailed(command: String, reason: String)
    /// A Kit runner was not supplied to the CLI context.
    case runnerUnavailable

    /// The process status appropriate for this runtime error.
    package var exitStatus: Int32 {
        switch self {
        case .configurationNotFound, .configurationReadFailed, .missingHomeDirectory:
            78
        case .lockOpenFailed, .lockOperationFailed:
            73
        case .commandNotFound:
            127
        case .commandNotExecutable:
            126
        case .processSpawnFailed, .processWaitFailed, .runnerUnavailable:
            70
        }
    }

    /// A message suitable for stderr.
    package var description: String {
        switch self {
        case .missingHomeDirectory:
            "HOME is unavailable; set HOME or XDG_CONFIG_HOME, or pass --config explicitly"
        case let .configurationNotFound(path):
            "configuration file not found: \(path)"
        case let .configurationReadFailed(path, reason):
            "could not read configuration at \(path): \(reason)"
        case let .lockOpenFailed(path, reason):
            "could not open command queue lock at \(path): \(reason)"
        case let .lockOperationFailed(path, reason):
            "command queue lock failed at \(path): \(reason)"
        case let .commandNotFound(command):
            "command not found: \(command)"
        case let .commandNotExecutable(command):
            "command is not executable: \(command)"
        case let .processSpawnFailed(command, reason):
            "could not start \(command): \(reason)"
        case let .processWaitFailed(command, reason):
            "could not wait for \(command): \(reason)"
        case .runnerUnavailable:
            "command queue runner is unavailable"
        }
    }
}
