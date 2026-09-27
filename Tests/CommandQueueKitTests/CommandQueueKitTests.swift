@testable import CommandQueueKit
import Testing

struct CommandQueueKitTests {
    @Test("returns the starter greeting")
    func greeting() {
        #expect(CommandQueueKit.greeting() == "Hello from CommandQueue")
    }
}
