# RTK

Prefix every shell command with `rtk`.

Use `distill` for tests, builds, logs, broad searches, diffs, audits, and output likely to exceed 200 lines:

```bash
<command> 2>&1 | distill "<exact required result>"
```

Do not use `distill` when exact source text is required or output is expected to remain below 200 lines.

## Execution efficiency

A narrow task is one that names a specific file, test, error, function, or local behaviour.

For narrow tasks:

- Make at most two investigative shell calls before the first edit.
- Batch independent file reads and searches into one shell call.
- Read only the target file, its direct implementation, and at most one nearby example.
- Do not load documentation unless the task changes architecture, contracts, public behaviour, deployment, or external integrations.
- Do not search for a path that is already known.
- Do not inspect `package.json` merely to rediscover commands documented in repository instructions.
- Do not run a flaky or nondeterministic test before editing when the user supplied the failure and reproduction command.
- After editing, use one combined validation command.
- Do not run `git diff` merely to summarize a patch just applied.
- Do not rerun a targeted test after a successful repeated-test validation.
- Stop when the requested change and required targeted validation succeed.

For broad, architectural, cross-module, security-sensitive, or unclear tasks, these narrow-task limits do not apply.

## Long-running commands

For commands expected to exceed 30 seconds:

- Start with `yield_time_ms: 30000`.
- Poll only with empty input and `yield_time_ms: 300000`.
- Do not restart a quiet command.
- Do not provide routine polling updates.
