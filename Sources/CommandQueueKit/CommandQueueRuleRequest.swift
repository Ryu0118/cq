/// Input shared by direct-only rule management operations.
package struct CommandQueueRuleRequest: Sendable {
    /// Optional path to a command policy file.
    package let configPath: String?
    /// Environment used to resolve the default configuration path.
    package let environment: [String: String]

    /// Creates a rule-management request.
    package init(configPath: String?, environment: [String: String]) {
        self.configPath = configPath
        self.environment = environment
    }
}
