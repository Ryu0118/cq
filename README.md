# command-queue

`command-queue` (`cq`) is a macOS-first Swift executable and library for
serializing selected local commands across callers on the same machine.
Commands covered by the queue policy will be run through `cq`; commands
matching configured direct-only regular expressions must be invoked directly.

## Status

This repository currently contains the Swift package scaffold. Queue execution,
machine-wide coordination, and direct-only regex policy are planned and have not
been implemented. The current CLI is the template starter command.

## Development setup

Requirements: macOS 15 or later, Swift 6, and mise 2026.7.5 or later.

```sh
# Install/update the project tools, configure Git hooks, and initialize docs.
mise run setup

# Build the package and run its checks.
mise run build
mise run test
mise run check

# Run the CLI scaffold.
mise run run
swift run cq --help
```

The `CommandQueueCLI` target owns command-line parsing, while reusable behavior
belongs in `CommandQueueKit`.
