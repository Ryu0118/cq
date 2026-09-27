import Foundation

/// Rejects commands that configuration requires callers to run directly.
package struct DirectOnlyCommandPolicy: Sendable {
    private let patterns: [String]

    /// Creates a policy from regular expression patterns.
    package init(patterns: [String]) {
        self.patterns = patterns
    }

    /// Throws when the joined executable and arguments match a direct-only pattern.
    package func validate(command: [String]) throws {
        guard !command.isEmpty else {
            throw CommandQueueError.emptyCommand
        }

        let commandLine = command.joined(separator: " ")
        let range = NSRange(commandLine.startIndex..., in: commandLine)

        for pattern in patterns {
            let expression = try Self.regularExpression(for: pattern)

            if expression.firstMatch(in: commandLine, range: range) != nil {
                throw CommandQueueError.directOnly(command: commandLine, pattern: pattern)
            }
        }
    }

    /// Checks that a rule can be compiled as a regular expression.
    package static func validate(pattern: String) throws {
        _ = try regularExpression(for: pattern)
    }

    private static func regularExpression(for pattern: String) throws -> NSRegularExpression {
        guard !pattern.isEmpty else {
            throw CommandQueueError.invalidDirectOnlyPattern(
                pattern: pattern,
                reason: "the pattern must not be empty"
            )
        }

        do {
            return try NSRegularExpression(pattern: pattern)
        } catch {
            throw CommandQueueError.invalidDirectOnlyPattern(
                pattern: pattern,
                reason: error.localizedDescription
            )
        }
    }
}
