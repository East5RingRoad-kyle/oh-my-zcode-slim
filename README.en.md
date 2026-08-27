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
each other** (hub-and-spoke; all routing goes through the main agent).

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

Permission boundaries are two-layer: behavioral constraints in each role
prompt (soft) + per-subagent `tools` allowlists in ZCode (hard —
explorer/oracle/librarian simply have no write tools).

## Install

```bash
git clone <this-repo> ~/oh-my-zcode-slim
cd ~/oh-my-zcode-slim
./install.sh
```

Restart your ZCode session. Uninstall: `./uninstall.sh`.

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
stronger models (high/max) for oracle/fixer.

## Usage

- **Automatic**: start a multi-lane non-trivial task; the main agent loads
  `omzs-dispatch` and orchestrates on its own.
- **Explicit**: say "orchestrate this" / "run this big refactor with the
  deepwork workflow".
- Dispatch syntax: the Agent tool with `subagent_type: "explorer"` etc.
  (full template inside the dispatch skill).

## Design trade-offs (vs oh-my-opencode-slim)

Dropped: runtime preset switching, council multi-model arbitration, the
desktop companion, multiplexer panes, AST tooling, background wake
scheduling. Kept: the minimal viable core — roles + routing contract +
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
