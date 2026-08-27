# ✨ oh-my-zcode-slim ✨

[简体中文](README.md) | **English**

A lean multi-agent orchestration suite for ZCode: **9 native subagents
(including two council seats) + an orchestrator skill for the main agent**. Pure markdown,
zero compiled code.

> This project is a derivative work of
> [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
> (by alvinunreal / Boring Dystopia Development, MIT License). The role
> prompts and routing table are adapted from the original's
> `src/agents/*.ts`. See [NOTICE](NOTICE).

## What it is

You keep talking to the main agent as usual. Once it loads `omzs-dispatch`
it becomes the orchestrator: it breaks work into lanes, routes each lane to
the best-suited specialist subagent, then reconciles results into one
report. **You never invoke specialists by hand, and specialists never call
each other** (hub-and-spoke; all routing goes through the main agent —
auto-matching is best-effort; say "orchestrate this" if it doesn't fire).

| Role | Lane | Tools |
|---|---|---|
| main agent (orchestrator) | plan, route, dispatch, reconcile | unrestricted |
| `explorer` | fast codebase recon: "where is X" | read-only (no write tools, hard constraint) |
| `oracle` | architecture advisor, reviewer, YAGNI enforcement | read-only (hard constraint) |
| `librarian` | external docs research, fresh API usage | read-only + web |
| `fixer` | bounded implementer: implements, doesn't plan/research | unrestricted (Edit/Write available) |
| `designer` | frontend UI/UX specialist | unrestricted |
| `observer` | visual analysis of images/screenshots/PDFs, exact OCR | read-only (hard constraint) |
| `council` + two `councillor`s | multi-perspective arbitration: two independent analysts in parallel, a synthesizer produces one answer | councillors read-only; council zero tools |

Plus the `omzs-deepwork` skill: a phased workflow for large high-risk
changes (phase file + oracle review gates + per-phase commits).

Permission boundaries are three layers, stated honestly:
1. **Tool allowlists (hard)**: read-only roles have no Edit/Write; observer
   and both councillors have no Bash either; council has an empty tool set
   (pure text-in/text-out); fixer/designer have web tools disabled
   (Agent/Task/WebFetch/WebSearch).
2. **permissionMode: default (semi-hard)**: Bash write operations from
   explorer/oracle/librarian trigger user confirmation.
3. **Prompt discipline (soft)**: the read-only rules in each role script.
Bash can theoretically still reach write paths (`sed -i` etc.) — layers 2
and 3 exist for that; weigh the risk yourself in `bypassPermissions`
sessions.

## Install

```bash
git clone <this-repo> ~/oh-my-zcode-slim
cd ~/oh-my-zcode-slim
./install.sh
```

Restart your ZCode session (new session, or relaunch the app).
Uninstall: `./uninstall.sh` (use `--scope workspace` if installed that way,
`--all` for both; only files carrying this project's marker are removed).

The installer does two things:

1. Copies `agents/*.md` to `~/.zcode/agents/` — the nine roles appear
   immediately under Settings → Subagents → Installed.
2. Copies `skills/omzs-*` to `~/.agents/skills/` and symlinks them into
   `~/.zcode/skills/` (orchestration skills for the main agent).

Options: `--scope workspace` installs the agents into the current
project's `.zcode/agents/` (project-only); `ZCODE_HOME` /
`AGENTS_SKILLS_DIR` / `ZCODE_SKILLS_DIR` env vars override target paths.

**Note**: reinstalling overwrites installed copies. If you edited a
specialist via the ZCode settings UI, it is backed up first as
`<name>.md.omzs-backup.<timestamp>`. To make changes stick, edit
`agents/*.md` in the repo and reinstall.

**30-second self-check after install**: open a new ZCode session →
Settings → Subagents should list 9 roles; typing `/` should show
omzs-dispatch / omzs-deepwork; then ask "where is X in this repo" and watch
for an explorer dispatch.

**Updating**: `git pull && ./install.sh`. Roles you edited in the settings
UI are backed up automatically as `<name>.md.omzs-backup.<timestamp>`;
skill-side local edits are NOT backed up — edit the repo sources instead.

**Troubleshooting**: roles missing → check `~/.zcode/agents/` has 9 .md
files (and point `ZCODE_HOME` at your storage.dir root if customized);
skill not firing → say "orchestrate this" to force it; commit or gitignore
the `.slim/deepwork/` phase files in your project separately.

## Model config (optional)

**No config = every role inherits the session model; it just works**
(frontmatter `model: "inherit"`).

To pin models per role, open **Settings → Subagents** after installing:
each specialist has model and thought-level dropdowns on the right, exactly
like tuning the built-in Explore agent — enforced natively by ZCode. You
can also edit the frontmatter of `~/.zcode/agents/<name>.md` directly
(`model:` / `thoughtLevel:`), or install a project-scoped set with
`--scope workspace`.

Suggested pairing: fast/cheap models (Flash) for explorer/librarian,
stronger models (high/max) for oracle/fixer; **give the two council seats
different models** (e.g. alpha on provider A, beta on provider B, council
itself on a strong model) — same-model seats are legal but weak.

## Usage

- **Automatic**: start a multi-lane non-trivial task; the main agent loads
  `omzs-dispatch` and orchestrates on its own.
- **Explicit**: say "orchestrate this" / "run this big refactor with the
  deepwork workflow" (auto-matching is best-effort; force it when needed).
- Dispatch syntax: the Agent tool with `subagent_type: "explorer"` etc.
  (full template inside the dispatch skill).

## Design trade-offs (vs oh-my-opencode-slim)

Dropped: runtime preset switching, the desktop companion, multiplexer
panes, AST tooling, background wake scheduling. Council multi-model
arbitration is kept in manual form: assign different models to the two
seats in settings (the original switches models at runtime). Kept: the minimal viable core — roles + routing contract +
permission boundaries. One improvement over the original: OMO registers
agents through OpenCode's plugin API, while ZCode supports markdown
subagent definitions natively — so this needs no plugin mechanism at all;
`git clone` + one script and you're done.

## Acknowledgments

- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) —
  MIT License, Copyright (c) 2025 alvinunreal. This project borrows heavily
  from its agent prompt design and routing philosophy.

## License

MIT — see [LICENSE](LICENSE) (includes the original author's copyright
notice) and [NOTICE](NOTICE).
