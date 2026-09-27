import CommandQueueCLI

@main
enum CommandQueue {
    static func main() async {
        await CommandQueueCommand.main()
    }
}
