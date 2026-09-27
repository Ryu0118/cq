/// A command rejected by the queue policy.
package enum CommandQueueError: Error, Equatable, Sendable, CustomStringConvertible {
    /// No executable was provided.
    case emptyCommand
    /// A queued child tried to acquire the queue again.
    case nestedQueueInvocation
    /// The command matches a policy that forbids queue execution.
    case directOnly(command: String, pattern: String)
    /// A policy pattern cannot be compiled.
    case invalidDirectOnlyPattern(pattern: String, reason: String)

    /// The process status appropriate for this error.
    package var exitStatus: Int32 {
        switch self {
        case .emptyCommand, .nestedQueueInvocation, .directOnly:
            64
        case .invalidDirectOnlyPattern:
            78
        }
    }

    /// A message suitable for stderr.
    package var description: String {
        switch self {
        case .emptyCommand:
            "no command was provided"
        case .nestedQueueInvocation:
            "cq cannot be invoked from a command it already started"
        case let .directOnly(command, pattern):
            "command matches direct-only pattern \(pattern.debugDescription): \(command)"
        case let .invalidDirectOnlyPattern(pattern, reason):
            "invalid direct-only regex \(pattern.debugDescription): \(reason)"
        }
    }
}
