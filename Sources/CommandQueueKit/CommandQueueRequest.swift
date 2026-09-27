/// Input needed to run one command through the machine-local queue.
package struct CommandQueueRequest: Sendable {
    /// Executable and arguments, as received from the command line.
    package let command: [String]
    /// Optional path to a command policy file.
    package let configPath: String?
    /// Environment passed to configuration loading and the child process.
    package let environment: [String: String]

    /// Creates a command execution request.
    package init(command: [String], configPath: String?, environment: [String: String]) {
        self.command = command
        self.configPath = configPath
        self.environment = environment
    }
}
