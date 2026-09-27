# command-queue

`command-queue` (`cq`) is a macOS-first Swift command proxy and library. Its
planned behavior is to serialize selected commands across independent callers
on one machine. Commands matched by configured direct-only regular expressions
must be invoked directly and must not pass through `cq`.

The current repository is a package scaffold. Machine-wide queueing and regex
policy are not implemented yet; the CLI still contains the template starter
command.

## Package structure

- `CommandQueue` is the `@main` composition root.
- `CommandQueueCLI` owns argument parsing and command dispatch.
- `CommandQueueKit` will contain reusable queue and policy logic.
- Keep dependencies pointed inward: the executable may depend on CLI, and CLI
  may depend on Kit.

When implementing queueing, coordinate across separate `cq` processes and
terminal sessions on the same host. Enforce direct-only regex rules at the
proxy boundary before launching a child process.

## Development workflow

- `mise run setup` installs or updates project tools, configures Git hooks,
  formats sources, and initializes docsync checksums.
- `mise run build` builds the package.
- `mise run test` runs Swift Testing suites.
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
