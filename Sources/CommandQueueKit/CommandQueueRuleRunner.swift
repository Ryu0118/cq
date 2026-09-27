/// Manages direct-only command rules in the user's configuration.
package struct CommandQueueRuleRunner: Sendable {
    private let persistence: any CommandQueueDirectOnlyRulePersisting

    /// Creates a runner with the configuration persistence adapter.
    package init(persistence: some CommandQueueDirectOnlyRulePersisting) {
        self.persistence = persistence
    }

    /// Lists the configured rules.
    package func list(_ request: CommandQueueRuleRequest) throws -> [String] {
        try persistence.loadRules(configPath: request.configPath, environment: request.environment)
    }

    /// Adds a valid rule unless the same pattern is already present.
    package func add(_ pattern: String, to request: CommandQueueRuleRequest) throws {
        try DirectOnlyCommandPolicy.validate(pattern: pattern)
        var rules = try persistence.loadRules(configPath: request.configPath, environment: request.environment)
        guard !rules.contains(pattern) else {
            throw CommandQueueError.duplicateDirectOnlyPattern(pattern)
        }

        rules.append(pattern)
        try persistence.saveRules(rules, configPath: request.configPath, environment: request.environment)
    }

    /// Removes one exact rule string.
    package func remove(_ pattern: String, from request: CommandQueueRuleRequest) throws {
        var rules = try persistence.loadRules(configPath: request.configPath, environment: request.environment)
        guard let index = rules.firstIndex(of: pattern) else {
            throw CommandQueueError.directOnlyPatternNotFound(pattern)
        }

        rules.remove(at: index)
        try persistence.saveRules(rules, configPath: request.configPath, environment: request.environment)
    }
}
