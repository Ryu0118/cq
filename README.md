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

Requires macOS 15 or later.

### Install a release with mise

Requires [mise](https://mise.jdx.dev/). Install the latest published release
globally with:

```sh
mise use -g 'github:Ryu0118/cq[asset_pattern=cq-{{ version }}-darwin-universal.tar.gz]'
```

The release workflow publishes a universal macOS binary. There is no published
release yet; this command will work after the first release is created from the
GitHub Actions **Publish Release** workflow.

### Build from source

Requires Swift 6 or later.

```sh
git clone git@github.com:Ryu0118/cq.git
cd cq
swift build -c release
mkdir -p "$HOME/.local/bin"
cp .build/release/cq "$HOME/.local/bin/cq"
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
is optional and is created when the first rule is added. Manage rules with:

```sh
cq add-rule '^xcodebuild\s+archive(?:\s|$)'
cq list-rules
cq remove-rule '^xcodebuild\s+archive(?:\s|$)'
```

`remove-rule` removes the exact pattern string shown by `list-rules`. Use
`--config <path>` to select another file, for example
`cq add-rule --config ./cq.json '^xcodebuild\s+archive(?:\s|$)'`.
`cq list-rule` is also accepted as an alias for `cq list-rules`.

You can also edit the JSON file directly:

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
cq [--config <path>] <command> [args...]
cq add-rule [--config <path>] <regex>
cq list-rules [--config <path>]
cq remove-rule [--config <path>] <regex>
cq run <command> [args...]
cq --help
cq --version
```

| Option | Description |
|---|---|
| `--config <path>` | Use a specific JSON policy file. |
| `--help` | Show command usage. |
| `--version` | Show the current version. |

Use `cq run <command>` when the executable name is one of cq's reserved
subcommands (`run`, `add-rule`, `list-rules`, `list-rule`, or `remove-rule`).

## License

No license file is currently included.
