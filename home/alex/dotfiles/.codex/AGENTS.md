## RTK

Prefix every shell command with `rtk`.

## Distill

Distill exposes two MCP tools: `context` and `run`. It replaces the capable agent's initial broad repository-discovery and source-reading pass, and reduces command-output cost. It does not replace task understanding, implementation reasoning, code review, or correctness decisions.

### Repository context

For broad, cross-module, architectural, security-sensitive, review, merge, or unclear work, use this order:

1. Read and understand the authoritative task, specification, review finding, backlog entry, or merge request yourself.
2. Form a complete repository-context objective from that understanding.
3. Before broad source, caller, test, or documentation discovery, call `distill.context` with `action: "gather"`, the objective, and task IDs, symbols, paths, branches, or issue references.
4. Use `inlineEvidence` only for evidence that exists solely in the user prompt.

Distill performs one bounded Spark pass and returns one flat, deduplicated bundle containing exact source from direct implementation owners, boundary callers, representative tests, completed mechanical searches, and validation commands. It does not diagnose, advise, recommend solutions, or produce an implementation plan.

- Treat the returned exact source as the initial repository read pass; do not immediately reread it.
- Do not repeat searches listed as completed.
- Do not call context again for the same objective.
- Perform only targeted follow-up reads when editing requires surrounding code or implementation reveals a genuinely new detail.
- If secondary source is listed only as a precise location because the one-response budget was reached, read it only if the active part of the task needs it.

Each capable agent must read the authoritative task itself and request its own context. A review agent should inspect the diff itself and use Distill only for surrounding repository context. Skip `distill.context` for narrow work that already has sufficient local context.

### Command output

Use `distill.run` for test, build, lint, formatting, typecheck, validation, log, or mechanical search commands whose output may be large, noisy, or empty. Distill executes the command itself and always returns its exit status.

Good uses:

- Test, build, lint, formatting, and typecheck output where failures and locations matter.
- Combined final validation.
- Broad mechanical search output where only matching paths and lines matter.
- Logs expected to exceed 200 lines and commands that may succeed silently.

Do not ask `distill.run` to review or audit code or diffs, find requirement gaps or design problems, decide correctness, or replace exact source/diff reading. Always ask for the exit code. Do not pipe command output into Distill, and do not use it when exact source text is required.

## Execution efficiency

A narrow task is one that names a specific file, test, error, function, or local behaviour.

For narrow tasks:

- Batch independent file reads and searches into one shell call.
- Do not load documentation unless the task changes architecture, contracts, public behaviour, deployment, or external integrations.
- Do not search for a path that is already known.
- Do not inspect `package.json` merely to rediscover commands documented in repository instructions.
- Do not run a flaky or nondeterministic test before editing when the user supplied the failure and reproduction command.
- After editing, use one combined validation command.
- Do not run `git diff` merely to summarize a patch just applied.
- Do not rerun a targeted test after a successful repeated-test validation.

For broad, architectural, cross-module, security-sensitive, or unclear tasks, these narrow-task limits do not apply.

- After retrieving Distill context, do not repeat its completed searches or broadly reread included exact source. Use only targeted additional reads that remain necessary.

All final validation must run in one `distill.run` call, including formatting, build, lint, type checking, and affected tests. Do not return to the model between successful validation commands. Return one bounded combined result.

Do not reread an unchanged file or line range already present in the session.
When output truncates, narrow the next read instead of repeating the original read.

## Long-running commands

For commands expected to exceed 30 seconds:

- Start with `yield_time_ms: 30000`.
- Poll only with empty input and `yield_time_ms: 300000`.
- Do not restart a quiet command.
- Do not provide routine polling updates.
