/// Resolved policy and lock path for one queue request.
package struct CommandQueueRuntimeSettings: Sendable {
    /// Stable lock file shared by every local account on this machine.
    package static let machineLockFilePath = "/tmp/command-queue.lock"

    /// The direct-only command policy.
    package let configuration: CommandQueueConfiguration
    /// The stable lock file shared by all machine-local invocations.
    package let lockFilePath: String

    /// Creates resolved runtime settings.
    package init(configuration: CommandQueueConfiguration, lockFilePath: String) {
        self.configuration = configuration
        self.lockFilePath = lockFilePath
    }
}
