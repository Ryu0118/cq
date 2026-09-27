/// Input needed to acquire the machine-local command queue.
package struct CommandQueueRequest: Sendable {
    /// Executable and arguments, as received from the command line.
    package let command: [String]
    /// Path shared by all command-queue invocations on this machine.
    package let lockFilePath: String
    /// Policy patterns checked before waiting for the queue.
    package let directOnlyPatterns: [String]

    /// Creates a queue request.
    package init(command: [String], lockFilePath: String, directOnlyPatterns: [String]) {
        self.command = command
        self.lockFilePath = lockFilePath
        self.directOnlyPatterns = directOnlyPatterns
    }
}
