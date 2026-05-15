# RTK - Rust Token Killer (Codex CLI)

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

## Meta Commands

```bash
rtk gain            # Token savings analytics
rtk gain --history  # Recent command savings history
rtk proxy <cmd>     # Run raw command without filtering
```

## Verification

```bash
rtk --version
rtk gain
which rtk
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

Prompts must be explicit. Say exactly what to return.

Good examples:

`rtk pnpm test --reporter=agent 2>&1 | distill "Did tests pass? Return only PASS or FAIL, failing test names, and the first actionable error."`
`rtk git diff 2>&1 | distill "Summarize changed files. Return only file path, one-line change summary, and risk."`
`rtk rg -n "TODO|FIXME" . 2>&1 | distill "Return only matching file paths and line numbers."`
`rtk npm audit 2>&1 | distill "Extract vulnerabilities. Return valid JSON only with package, severity, fixAvailable."`
`rtk terraform plan 2>&1 | distill "Return SAFE, REVIEW, or UNSAFE, then exact risky changes only."`
`rtk ls -la 2>&1 | distill "Return only filenames."`
