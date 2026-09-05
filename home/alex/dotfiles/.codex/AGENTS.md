## Shell

Prefix every shell command with `rtk`.

## Repository context

Use direct targeted reads when the implementation is already localized to a known owner and adjacent tests.

Treat work as broad when the implementation owner is unclear, it crosses modules or architectural layers, or it requires tracing callers, usages, dependencies, or related tests. Named files, functions, tests, errors, or local behaviours alone do not make a task narrow.

For broad work:

1. Read and understand the authoritative task, specification, review finding, backlog entry, or merge request yourself.
2. Before broad source, caller, test, or documentation discovery, call `distill.context` once with `action: "gather"`, a complete objective, and useful task IDs, symbols, paths, branches, or issue references.
3. Use `inlineEvidence` only for evidence that exists solely in the user prompt.
4. Treat returned exact source and completed searches as already read. Make only targeted follow-up reads for specific context still required to edit or reason correctly.

Do not repeat completed searches, broadly reread source already returned by Distill, or call `distill.context` again for the same objective.

## Command output

Use `distill.run` for tests, builds, lint, formatting, type checks, logs, or mechanical searches whose output may be large, noisy, or empty. Use native tools when exact source or diff text is required. Do not pipe command output into Distill.

Keep ordinary source and search output bounded: prefer targeted ranges and searches, do not concatenate several large files, and if output truncates narrow the next read rather than repeating or broadening it.

Do not reread an unchanged file or line range already present in the session.

## Validation

Run repository-required checks appropriate to the change. Once required checks pass, broaden or repeat verification only when later edits, failures, or unresolved concerns justify it.

After partial validation failure, rerun only failed checks and previously passing checks that the subsequent edit could realistically invalidate. Do not rerun a known unrelated failing check unless the task changed code relevant to it.

When final validation has multiple noisy stages, prefer one `distill.run` call so the parent model receives one bounded result.

## Long-running commands

For commands expected to exceed 30 seconds:

- Start with `yield_time_ms: 30000`.
- Poll only with empty input and `yield_time_ms: 300000`.
- Do not restart a quiet command.
- Do not provide routine polling updates.

## Optional Gortex

Use the `rtk gortex` CLI when graph relationships can answer a genuinely unresolved repository question more efficiently than ordinary search. It is optional; prefer normal tools for known-file reads, exact searches, edits, and diffs.

Useful forms:

- `rtk gortex explore "<task>" --index "$PWD" --format toon --max-symbols 12 --no-progress`
- `rtk gortex query symbol "<name>" --index "$PWD" --format text --limit 10`
- `rtk gortex query callers|calls|usages|deps|dependents|implementations "<symbol-id>" --index "$PWD" --format text --limit 30`

If Gortex is unavailable or the repository is untracked, fall back immediately to normal repository tools. Do not start, restart, track, or reconfigure Gortex automatically.
