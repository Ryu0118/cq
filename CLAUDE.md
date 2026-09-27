# command-queue

`command-queue` (`cq`) is a macOS Swift command proxy. `cq -- <command>
[args...]` runs the executable directly while holding an exclusive `flock` on
`/tmp/command-queue.lock`. The shared lock serializes cooperating `cq`
processes across local user accounts on this machine. The child inherits the
terminal streams and its exit status is returned by `cq`.

Direct command invocations bypass the queue. All callers that need
serialization must use `cq`. The lock file must stay in place: unlinking it
could let processes waiting on the old inode run concurrently with processes
locking a newly created file. The file has no content and is made readable by
all local users so each account can acquire the same advisory lock.

The optional `--config <path>` selects a JSON policy file. By default, `cq`
loads `$XDG_CONFIG_HOME/command-queue/config.json`, or
`~/.config/command-queue/config.json` when `XDG_CONFIG_HOME` is unset. Example:

```json
{
  "directOnlyPatterns": [
    "^signing-tool(?:\\s|$)",
    "^xcodebuild\\s+archive(?:\\s|$)"
  ]
}
```

Each regex is matched against the executable and its arguments joined with
spaces. A match is rejected before the process waits for the machine lock.
Nested `cq` invocations from a queued child are rejected to avoid deadlock.

## Package structure

- `CommandQueue` is the `@main` composition root.
- `CommandQueueCLI` owns argument parsing, Kit request construction, POSIX adapters, and outcome presentation. It does
  not sequence the command execution workflow.
- `CommandQueueKit` owns command policy and complete queue workflow sequencing: loading configuration through a
  protocol, checking policy, managing lock lifetime, and running the child through injected protocols. CLI supplies
  the concrete file, lock, and process adapters.
- Dependencies point inward: the executable may depend on CLI, and CLI may
  depend on Kit.

## Development workflow

- `mise run setup` installs or updates project tools, configures Git hooks,
  formats sources, and initializes docsync checksums.
- `mise run build` builds the package.
- `mise run test` runs the existing Swift Testing suites.
- `mise run check` runs formatting, lint, AST lint, build, tests, and docsync.
- See `.mise.toml` and `mise tasks` for task definitions.
- Git hooks in `.githooks/`: pre-commit runs gitleaks, formatting, lint, AST
  lint, and docsync; pre-push runs AST lint.
- Keep commits small and easy to revert.

## Coding rules

Read these before writing or reviewing code. They are the source of truth;
`.claude/rules` points to `.agents/rules`:

- `.agents/rules/coding-rules.md` — SSoT / DRY / SOLID, layering, runners,
  side effects, errors, and tests.
- `.agents/rules/swift-coding.md` — files, access control, comments,
  abstraction, concurrency, and testing conventions.
- `.agents/rules/code-review.md` — review and refactoring checklist.
- `.agents/rules/lint-and-format.md` — SwiftFormat, SwiftLint, and AST linter
  requirements.
- `.agents/rules/workflow.md` — commit size, Git hooks, docsync, and CI.

Use `package` access for symbols shared within the package and `public` only
for symbols consumed outside it.
