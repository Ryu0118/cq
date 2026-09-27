/// Reads and writes direct-only rules for a user's command-queue configuration.
package protocol CommandQueueDirectOnlyRulePersisting: Sendable {
    /// Loads the rules from the selected configuration, returning an empty list when it does not exist yet.
    func loadRules(configPath: String?, environment: [String: String]) throws -> [String]

    /// Saves the rules to the selected configuration, creating it when needed.
    func saveRules(_ rules: [String], configPath: String?, environment: [String: String]) throws
}
