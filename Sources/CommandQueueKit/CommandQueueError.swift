/// A command rejected by the queue policy.
package enum CommandQueueError: Error, Equatable, Sendable, CustomStringConvertible {
    /// No executable was provided.
    case emptyCommand
    /// The command matches a policy that forbids queue execution.
    case directOnly(command: String, pattern: String)
    /// A policy pattern cannot be compiled.
    case invalidDirectOnlyPattern(pattern: String, reason: String)

    /// The process status appropriate for this error.
    package var exitStatus: Int32 {
        switch self {
        case .emptyCommand, .directOnly:
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
        case let .directOnly(command, pattern):
            "command matches direct-only pattern \(pattern.debugDescription): \(command)"
        case let .invalidDirectOnlyPattern(pattern, reason):
            "invalid direct-only regex \(pattern.debugDescription): \(reason)"
        }
    }
}
