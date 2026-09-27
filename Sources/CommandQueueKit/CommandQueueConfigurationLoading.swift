/// Loads the policy and machine-wide lock path used by a queue request.
package protocol CommandQueueConfigurationLoading: Sendable {
    /// Resolves configuration from an optional file path and the invocation environment.
    func load(configPath: String?, environment: [String: String]) throws -> CommandQueueRuntimeSettings
}
