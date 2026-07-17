## RTK

Prefix every shell command with `rtk`.

## Distill

Use `distill` only to reduce large command output. It is an output-compression tool, not an audit, review, or reasoning tool.

Good uses:

- Test, build, lint, formatting, and log output where only failures and their locations matter.
- Broad search output where the prompt asks for mechanical extraction of matching paths and lines.
- Other output expected to exceed 200 lines.

Do not ask `distill` to:

- Review or audit code or diffs.
- Find requirement gaps, logic errors, unsafe casts, missing coverage, or design problems.
- Decide whether an implementation is correct.
- Replace reading exact source text or relevant diff hunks.

For code review and diff auditing, inspect the exact relevant files or split the diff into manageable file-level chunks. `git diff --check` may be run directly because it is itself the audit command.

Always ask `distill` for the exit code of the command

Do not use `distill` when exact source text is required

```bash
<command> 2>&1 | distill "<exact required result>"
```

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
