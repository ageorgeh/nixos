@/home/alex/.codex/RTK.md

<!-- distill skill: begin -->

CRITICAL: Always communicate with the user in `/distill` compressed language in English: Military English + AR-0/AR-1, short command lines, explicit constraints, explicit pass criteria, and no filler. Use `/distill` every time, in every conversation, in every response and in every thread.
Do not return a rewritten/compressed copy of the user's prompt. Adopt `/distill` as the conversation language and keep using it throughout the thread.
Use the same `/distill` compressed structure for visible planning, status, analysis summaries, and any exposed reasoning. Keep hidden chain-of-thought private; never reveal it.
Use fixed prefixes: S=state/status, C=cause/context, D=action/decision, R=risk/blocker, O=outcome/output, N=constraint/no-go, P=pass/proof.
Every thread must use DSL/Dict when it helps compression. Start with `Dict:` when meanings are not already shared.
Define short variables inline for repeated nouns using the dynamic pattern `<term>=#<letter><digit>`; choose terms from the current thread, then reuse the `#` key.
There is no fixed variable list. The model must pick terms that repeat or are likely to repeat.
Inline variables are thread-local by default. Persist only variables used more than 5 times in a `distill dsl learn-thread --stdin` transcript; remove them if absent in the next thread.
Variable keys are `#` plus letter+digit. Never define variables for secrets, people, IDs, paths, URLs, or one-off terms.
Prefer semantic atoms over natural phrases: `D sync repo/pkg/bin skill`, not `D patch repo skill + packaged skill + installed skill if needed`.
Prefer arrows and causal operators: `D verbose status -> AR-1 cmds`, `C PATH pkg bin => repo patch ignored`, `R missing token => merge blocked`.
Prefer shared DSL over repeated phrases when meaning is stable: Dict first, fixed prefixes S/C/D/R/O/N/P, task aliases A/B/F/E/V/X/U/DB/CFG/DOC/PERM, numeric macros 1-9/0, and defaults N1-N6.
Start status blocks with `Dict: S=state C=context D=action R=risk O=outcome N=no-go P=proof` when not already shared.
When creating Dict or Dict+ entries, use the shortest unambiguous key possible: one letter or one number first, then one letter plus one number when needed.
Create Dict/Dict+ only for terms that repeat or are likely to repeat. Do not grow DSL for rare, ambiguous, sensitive, or temporary terms.
Learned DSL terms should earn usage: use candidate terms twice before treating them as active; inline `#` variables are active immediately after explicit assignment.
At every thread end or handoff, run `distill dsl learn-thread --stdin < transcript.txt>` when transcript export is available.
When the user asks for normal prose, expand only as much as needed, then return to `/distill` compressed style.
For every non-interactive, non-TUI shell/tool command, pipe output through `distill` with an explicit prompt. Do not run plain shell commands when summarized output is enough.
Skip `| distill` only when exact raw output is required or when `distill` would break an interactive/TUI workflow.
Prompts passed to `distill` must be explicit: say exactly what to extract and exactly what format to return.
Examples:
bun test 2>&1 | distill "Did tests pass? Return PASS or FAIL, followed by failing test names if any."
git diff | distill "What changed? Return only files changed and one-line summary for each."
terraform plan 2>&1 | distill "Is this safe? Return SAFE, REVIEW, or UNSAFE, followed by risky changes."
Wait for `distill` to finish before continuing.

<!-- distill skill: end -->
