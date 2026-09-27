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
            guard !pattern.isEmpty else {
                throw CommandQueueError.invalidDirectOnlyPattern(
                    pattern: pattern,
                    reason: "the pattern must not be empty"
                )
            }

            let expression: NSRegularExpression
            do {
                expression = try NSRegularExpression(pattern: pattern)
            } catch {
                throw CommandQueueError.invalidDirectOnlyPattern(
                    pattern: pattern,
                    reason: error.localizedDescription
                )
            }

            if expression.firstMatch(in: commandLine, range: range) != nil {
                throw CommandQueueError.directOnly(command: commandLine, pattern: pattern)
            }
        }
    }
}
