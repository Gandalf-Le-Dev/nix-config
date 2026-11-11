When running inside a herdr pane (HERDR_ENV=1), use herdr to manage panes, interact with interactive shell and allow user to input text and unlock situations otherwise swallowed by non interactive shell — treat it the way you'd otherwise use tmux.

Before opening a pane or tab (Rex, herdr, tmux), list the open ones and reuse a pane you opened for the same job, such as a rebuild or test pane. Send the command to it; run `exec zsh` there when you need a fresh shell. Open a new pane only when none fits, and label it by its job.

Work that is real but out of scope for the current repo goes to docket's `todo_add`, with `source` set to where you noticed it.

---
## Orchestration

### Subagents to preserve context

The main agent orchestrates and holds the user-facing thread. Subagents do work that would otherwise bloat the main context with intermediate output (file dumps, test logs, search results, scratch reasoning). Spawn a subagent when the work has a well-defined input and output and the middle is noise to the main thread.

Default split for non-trivial changes:
- **Main agent**: planning, decomposition, integrating results, talking to the user
- **Implementer subagent**: writes the code given a clear spec; returns a diff summary, not the full file dumps
- **Reviewer subagent**: reads the diff against the spec and the repo's conventions; returns a list of issues, not a re-narration of the code

The reviewer must be a separate subagent from the implementer. Same-context review tends to ratify what was just written; fresh context catches what familiarity hides.

Parallelize with Task when work is independent:
- Reading independent files across a large repo
- Searching multiple repos for the same pattern
- Running independent test suites
- Gathering context from unrelated subsystems before a plan

Sequential tool calls are fine for dependent work. Don't fan out to look busy.

### Model and effort routing

Every Agent call sets `model` and `effort` from this table, unless the agent file pins a `model:` in its frontmatter or I name one. This applies to built-in agents (Explore, Plan, general-purpose) and project agents alike. Forks ignore `model`, so use a typed agent when the task needs a different tier.

| Task | model | effort |
|---|---|---|
| Search, read files or logs, summarize, Explore | haiku | medium |
| Classify, tag, extract, other cheap-to-check bulk work | haiku | medium |
| Well-scoped edits: bug fix, spec-driven change, feature iteration | sonnet | medium |
| Repeated agent work: investigation, drafting, docs | sonnet | medium |
| Review, judgment calls, debugging, multi-PR features, vision | opus | medium |
| Harder version of any opus task | opus | high |
| Major refactor, migration, architecture, deep research, leading many subagents | fable | medium |
| Unsure | opus | medium |

A clear spec does not mean sonnet: a migration or perf optimization with a clear spec still goes to opus or fable. Code edits and judgment calls stay on sonnet or above, never haiku. The reviewer runs on a tier at least as high as the implementer.

Named agents ignore `effort`: with CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1, an Agent call with `name` runs at the session effort and keeps only `model` (Claude Code 2.1.322 bug). If an agent needs an effort different from the session's, do not set `name`; address it by its agent ID instead. Remove this paragraph once named agents honor `effort`.

Escalate in this order when a result is not good enough: give the agent a check it can run (test, build, script), then raise effort one level, then move up one model at a lower effort. Before raising opus past `high`, try fable at `high` instead. For batches with an automatic pass/fail check, run all at `low` and re-run only the failures at `high`.

### Context hygiene

A subagent is one job: one brief, one result, then done. For the next task, start a fresh agent with a new brief instead of resuming a finished one. Resume an agent only to follow up on its own result.

The lead suggests a fresh session at natural breaks: a plan phase or milestone is done, or the topic changes. It never cuts a session mid-task. Before the switch, it writes the state into the repo's plan docs (or a short handoff note) so the next session starts from files, not memory.

### Lead and deep sessions

The session the user talks to is the lead: opus at medium. It holds the discussion, decides, and integrates. It does not grind through hard thinking itself.

When the discussion reaches a subject that needs more thought than opus medium gives (a design decision with lasting consequences, a bug that survived one serious attempt, architecture, migration, deep research), the lead must open a deep session without asking first. Tell the user in one line: its name, its model and effort, and why. Pick model and effort from the routing table above, never lower than opus at high.

Deep sessions are full interactive Claude sessions, so the user can switch to them and talk directly. In-process subagents are not deep sessions, because the user cannot talk to them.

Launch, from the project root:

```sh
rex window new -s "$REX_SESSION" <name> -c "$PWD" --focus=false --json -- \
  claude --model <model> --effort <effort> -n <name> \
  --append-system-prompt "You are deep session <name>, started by lead session <lead>. Work the brief. The user can talk to you directly. When you reach a conclusion, send it to <lead> with SendMessage: decision, reasoning, open questions." \
  "<brief>"
```

When `HERDR_ENV=1`, open it as a herdr pane instead of a Rex tab, same command.

- `<name>`: two to four lowercase words joined by hyphens, naming the subject (`auth-token-design`).
- `<lead>`: this session's name, from `ListAgents`.
- `<brief>`: the question, what the discussion settled, what is ruled out, relevant file paths, and what a good answer looks like. The deep session sees nothing of the lead's context except this.

Talk to a deep session with `SendMessage` to its name. Fall back to `rex capture -s "$REX_SESSION" -b <block> --trim` if it does not reply. Never answer a deep session's trust or permission prompts with `rex send-key`; tell the user which tab is waiting. When a deep session's conclusion is in, relay it to the user, and tell the user the tab can be closed. Do not close it yourself.

Source: https://claude.dev/blog/which-claude-model-should-you-build-with/

### `/loop` to convergence

For tasks with an objective pass/fail signal (tests, lint, type-check, plan-clean), use `/loop` to drive cycles until both:
1. The objective signal is green, AND
2. The reviewer subagent returns no blocking issues

Each iteration:
1. **Implementer** makes a change toward the goal
2. **Signal check** runs the objective command (test/lint/plan/etc.)
3. **Reviewer** (fresh context, not the implementer) reads the diff against the spec and the repo's conventions, returns a structured list: blocking issues, suggestions, nits
4. If signal is red OR reviewer returns blocking issues → next iteration, feeding both back to the implementer
5. If signal is green AND reviewer has no blockers → exit

The reviewer is inside the loop, not after it. A green test suite with garbage code still iterates. A clean review with red tests still iterates.

Blocking vs non-blocking is the reviewer's call, but the categories are fixed:
- **Blocking**: correctness, security, violates a rule in this file or the relevant skill, breaks an interface contract, introduces a regression risk the tests don't cover
- **Suggestion**: real improvement, not required to ship
- **Nit**: style preference, ignorable

Only blockers gate the exit. Suggestions and nits get surfaced to the user at the end as a summary, not iterated on.

Cap iterations (default: 5). If the loop hasn't converged, stop and surface what's stuck — usually the spec is wrong, the signal is testing the wrong thing, or the reviewer and implementer disagree on something that needs a human call.

Good `/loop` targets:
- Failing test suite → all green AND review-clean
- Lint or vet errors → zero AND review-clean
- Terraform plan with unexpected changes → plan matches intent AND review-clean
- Type errors → clean compile AND review-clean

Bad `/loop` targets: anything where "done" is subjective at the spec level (style, naming, architecture). The reviewer can enforce specifics inside a loop, but it can't decide what the loop is for. Those need a human, not an automated cycle.

---

## Git

- Conventional commits, explaining *why* not *what*: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- Small, focused, atomic, tested. Each commit must be `git bisect`-safe.
- Always on a dedicated branch.
- Implementers should work in dedicated worktrees that are cleaned up once merged on main
- When `HERDR_ENV=1`, create worktrees with `herdr worktree create --branch <name> --no-focus` (open existing ones with `herdr worktree open`, clean up with `herdr worktree remove`), not `git worktree add`, `EnterWorktree`, or Agent `isolation: "worktree"`. This makes each worktree a herdr workspace the user can see. Point subagents at the returned path.
- Pre-commit hook should reject strings matching common secret patterns (`AKIA*`, `ghp_*`, `eyJ*`, `-----BEGIN`). If missing, offer to install it with `prek install`
- When closing a TODO item, update and commit the TODO file alongside the code change.
- Never sign as claude.

---

## Comments

Default to no comment. Code should be self-explanatory through naming and structure.

**Only write a comment when it answers *why*, never *what*.** If the comment restates what the code does, delete it and improve the code instead.

**Forbidden:**
- Restating the code in English (`// increment counter` above `counter++`)
- Section banners (`// --- HELPERS ---`)
- Narrating obvious control flow (`// loop through users`)
- TODOs without a ticket reference or owner
- Docstrings that just list parameters already visible in the signature
- Preamble explaining what you're about to do
- Marking what changed in this edit (`// updated to handle null`) — that's what the diff is for

**Acceptable, when truly needed:**
- Non-obvious *why*: business rule, spec reference, workaround for an external bug, performance trade-off, intentional deviation from the obvious approach
- Warnings about non-local consequences ("called by X under Y condition")
- Links to issues, RFCs, or external docs

**Style:** one line is the target. If the explanation needs more lines than the code, refactor instead. Re-read nearby comments when editing; delete or update any that no longer match.

---

## Code style

- No emojis in code, comments, or documentation.
- Documentation under `./docs/` at repo root; nested layout is fine.
- Structured logs everywhere (golang `log/slog`).

---

## Communication

- Drop filler: *just*, *really*, *basically*, *actually*, *simply*.
- Drop pleasantries: *sure*, *certainly*, *of course*, *happy to*.
- Prefer short synonyms: *big* not *extensive*, *fix* not *implement a solution for*.
- Abbreviate common terms: DB, auth, config.
- Technical terms stay exact. Code blocks unchanged. Errors quoted exact.
