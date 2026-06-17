# RTK 

**Usage**: Token-optimized CLI proxy for shell commands.

## Rule

Always prefix shell commands with `rtk`.

Examples:

```bash
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```
## Distill command-output policy

For non-interactive shell commands, compress command output through `distill` before reading it.

Required form:

```bash
<command> 2>&1 | distill "<specific extraction prompt>"
```

Do not run the same command raw first.

Use `distill` for:

- test output
- build output
- logs
- grep/search output
- git diff summaries
- audit/plan output
- long directory listings
- any noisy command where a summary is enough

Skip `distill` only when:

- reading agent skill files or AGENTS.md files
- exact raw output is required
- command output is machine-consumed by another command
- command is interactive/TUI/watch mode
- command creates or modifies files and output is not needed
- distill is unavailable or fails
- commands expected to produce under 200 lines

Prompts must be explicit. Say exactly what to return.

Good examples:

`rtk pnpm test --reporter=agent 2>&1 | distill "Did tests pass? Return only PASS or FAIL, failing test names, and all actionable errors"`
`rtk git diff 2>&1 | distill "Summarize changed files. Return only file path, one-line change summary, and risk."`
`rtk rg -n "TODO|FIXME" . 2>&1 | distill "Return only matching file paths and line numbers."`
`rtk npm audit 2>&1 | distill "Extract vulnerabilities. Return valid JSON only with package, severity, fixAvailable."`
`rtk terraform plan 2>&1 | distill "Return SAFE, REVIEW, or UNSAFE, then exact risky changes only."`
`rtk ls -la 2>&1 | distill "Return only filenames."`

## Long-running terminal commands

For builds, tests, type checks, formatting, distill, and other commands expected to take longer than 30 seconds:

- Start `exec_command` with `yield_time_ms: 30000`.
- If the command remains active, immediately call `write_stdin` with:
  - empty input
  - `yield_time_ms: 300000`
- Continue using 300000ms waits until the process exits.
- Never poll a running process with waits shorter than 30000ms.
- Never use 1000ms polling.
- Do not cancel, restart, or modify a command merely because it produced no output during a wait.
- Do not send progress commentary between terminal polls.

- Do not send progress updates for routine reads, edits, tests, builds, or polling.
- Report only a material finding, blocker, changed plan, or final result.