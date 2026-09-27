/// Policy loaded for a command-queue invocation.
package struct CommandQueueConfiguration: Sendable {
    /// Regular expressions that make matching commands direct-only.
    package let directOnlyPatterns: [String]

    /// Creates a command policy.
    package init(directOnlyPatterns: [String] = []) {
        self.directOnlyPatterns = directOnlyPatterns
    }
}
