@testable import CommandQueueCLI
import CommandQueueKit
import Testing

struct CommandQueueCommandTests {
    @Test("--version reports the Kit version")
    func versionMatchesKit() {
        #expect(CommandQueueCommand.configuration.version == CommandQueueVersion.current)
    }

    @Test("prints the Kit greeting through the injected output")
    func printsGreeting() async throws {
        let recording = RecordingOutput()
        let context = CLIContext(output: recording.output, environment: [:])
        try await CommandQueueCommand.parse([]).run(context: context)
        #expect(recording.standardOutput == [CommandQueueKit.greeting()])
        #expect(recording.standardError.isEmpty)
    }
}
