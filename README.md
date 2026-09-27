# command-queue

`command-queue` (`cq`) is a macOS command proxy that serializes commands
competing for build resources on one machine. Use `cq <command> [args...]` to
run a command through the queue, and configure regex rules for commands that
must run directly.

## Installation

Requires macOS 15 or later. Install after the first GitHub Release is published.

### Nest ([mtj0928/nest](https://github.com/mtj0928/nest))

```sh
nest install Ryu0118/cq
```

Nest builds cq from source, so Swift 6 or later is required.

### Mise ([jdx/mise](https://github.com/jdx/mise))

```sh
mise use -g github:Ryu0118/cq
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
