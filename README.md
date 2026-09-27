# command-queue

`command-queue` (`cq`) is a macOS command proxy and Swift package for running
selected commands one at a time across all local user accounts. It starts the
requested executable directly, holds a shared machine lock until that process
exits, and returns the command's exit status.

## Usage

```sh
cq -- xcodebuild -project App.xcodeproj build
cq -- swift build
```

The `--` marks the beginning of the command and its arguments. `cq` does not
invoke a shell; the child inherits the terminal's standard input, output, and
error streams. Direct invocations such as `xcodebuild ...` bypass the queue.

Direct-only commands can be blocked from the proxy with regular expressions in
the JSON configuration. The default path is
`$XDG_CONFIG_HOME/command-queue/config.json`, or
`~/.config/command-queue/config.json` when `XDG_CONFIG_HOME` is unset.

```json
{
  "directOnlyPatterns": [
    "^signing-tool(?:\\s|$)",
    "^xcodebuild\\s+archive(?:\\s|$)"
  ]
}
```

Patterns are matched against the executable and arguments joined with spaces.
Use anchors to limit a rule to the intended command. A rejected command exits
with status 64 before it waits for the machine lock.

The shared lock file is `/tmp/command-queue.lock`. `cq` leaves this file in
place because unlinking it could let waiting processes lock a different file.
All callers that need serialization must use `cq`; direct invocations do not
participate in the lock.

## Development setup

Requirements: macOS 15 or later, Swift 6, and mise 2026.7.5 or later.

```sh
# Install/update project tools, configure Git hooks, and initialize docs.
mise run setup

# Build the executable.
mise run build

# Run the command-line entry point or inspect its options.
mise run run
swift run cq --help
```

`CommandQueueCLI` owns command-line parsing and operating-system adapters;
`CommandQueueKit` contains reusable policy and queue coordination logic.
