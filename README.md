# command-queue

`command-queue` (`cq`) is a macOS command proxy that serializes commands
competing for build resources on one machine. Use `cq <command> [args...]` to
run a command through the queue, and configure regex rules for commands that
must run directly.

## Installation

Requires macOS 15 or later. After the first GitHub Release, install the latest
release globally with [mise](https://mise.jdx.dev/):

```sh
mise use -g 'github:Ryu0118/cq[asset_pattern=cq-{{ version }}-darwin-universal.tar.gz]'
```

To build from source, install Swift 6 or later:

```sh
git clone https://github.com/Ryu0118/cq.git
cd cq
swift build -c release
mkdir -p "$HOME/.local/bin"
cp .build/release/cq "$HOME/.local/bin/cq"
```

## Commands

```sh
# Install development tools and configure Git hooks.
mise run setup

# Build and test.
mise run build
mise run test

# Run all checks.
mise run check

# Run the executable.
mise run run
swift run cq --version
```

## Quick start

```sh
cq xcodebuild -project App.xcodeproj build
cq swift build
```

All callers must use `cq` to participate in serialization. Running a command
directly bypasses the queue. Arguments after the executable are passed through,
including options beginning with `-`.

## Direct-only commands

The default configuration path is
`$XDG_CONFIG_HOME/command-queue/config.json`, or
`~/.config/command-queue/config.json` when `XDG_CONFIG_HOME` is unset. The file
is optional and is created when the first rule is added.

```sh
cq add-rule '^xcodebuild\s+archive(?:\s|$)'
cq list-rules
cq remove-rule '^xcodebuild\s+archive(?:\s|$)'
```

`remove-rule` removes the exact pattern string shown by `list-rules`. Use
`--config <path>` to select another file, for example:

```sh
cq add-rule --config ./cq.json '^xcodebuild\s+archive(?:\s|$)'
```

Patterns match the executable and arguments joined with spaces. Use anchors to
limit a rule to the intended command. You can also edit the JSON file directly:

```json
{
  "directOnlyPatterns": [
    "^signing-tool(?:\\s|$)",
    "^xcodebuild\\s+archive(?:\\s|$)"
  ]
}
```

Use `cq run <command> [args...]` when the executable name is one of cq's
reserved subcommands: `run`, `add-rule`, `list-rules`, `list-rule`, or
`remove-rule`.
