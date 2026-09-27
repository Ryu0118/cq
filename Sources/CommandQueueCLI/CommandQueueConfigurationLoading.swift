/// Resolves a command's policy and machine-wide lock path.
package protocol CommandQueueConfigurationLoading: Sendable {
    /// Loads configuration and returns runtime settings.
    func load(configPath: String?, environment: [String: String]) throws -> CommandQueueRuntimeSettings
}
