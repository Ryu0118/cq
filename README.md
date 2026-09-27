# 🚦 command-queue

**Stop overlapping builds from competing for the same Mac.**

`command-queue` (`cq`) is a macOS command proxy for developers who share build
tools on one machine. Route commands through `cq` to make cooperating callers
take turns; configure regex rules for commands that must run directly.

## Features

- 🔒 **Avoid resource conflicts** — queued callers take turns across local accounts.
- 🚫 **Keep selected commands direct** — regex rules stop them from entering the queue.
- ↪️ **Keep the familiar CLI experience** — terminal streams and exit status pass through.

## Installation

Requires macOS 15 or later and Swift 6 or later.

```sh
git clone git@github.com:Ryu0118/cq.git
cd cq
swift build -c release
mkdir -p "$HOME/.local/bin"
cp .build/release/cq "$HOME/.local/bin/cq"
```

## Quick start

```sh
cq -- xcodebuild -project App.xcodeproj build
cq -- swift build
```

All callers must use `cq` to participate in serialization. Running a command
directly bypasses the queue.

## Direct-only commands

Add regular expressions to the JSON configuration to reject matching commands
before they enter the queue. The default path is
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

Patterns match the executable and arguments joined with spaces. Use anchors to
limit a rule to the intended command.

## Command reference

```sh
cq [--config <path>] -- <command> [args...]
cq --help
cq --version
```

| Option | Description |
|---|---|
| `--config <path>` | Use a specific JSON policy file. |
| `--help` | Show command usage. |
| `--version` | Show the current version. |

## License

No license file is currently included.
