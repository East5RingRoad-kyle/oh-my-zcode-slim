# ✨ oh-my-zcode-slim ✨

[简体中文](README.md) | **English**

A lean multi-agent orchestration suite for ZCode: one orchestrator + five
specialists (explorer / oracle / librarian / fixer / designer), delivered as
pure markdown skills — zero compiled code.

> This project is a derivative work of
> [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
> (by alvinunreal / Boring Dystopia Development, MIT License). The role
> prompts and routing table are adapted from the original's
> `src/agents/*.ts`. See [NOTICE](NOTICE).

## What it is

You keep talking to the main agent as usual. Once it loads `omzs-dispatch`
it becomes the orchestrator: it breaks work into lanes, routes each lane to
the best-suited specialist subagent, then reconciles results into one
report. **You never invoke specialists by hand.**

| Role | Lane | Access |
|---|---|---|
| orchestrator (the main agent you talk to) | plan, route, dispatch, reconcile | writable |
| `@explorer` | fast codebase recon: "where is X" | read-only |
| `@oracle` | architecture advisor, reviewer, YAGNI enforcement | read-only (advises, never implements) |
| `@librarian` | external docs research, fresh API usage | read-only |
| `@fixer` | bounded implementer: implements, doesn't plan/research | writable |
| `@designer` | frontend UI/UX specialist | writable |

Plus `omzs-deepwork`: a phased workflow for large high-risk changes (phase
file + oracle review gates + per-phase commits).

## Install

```bash
git clone <this-repo> ~/oh-my-zcode-slim
cd ~/oh-my-zcode-slim
./install.sh                # install skills (default, recommended)
./install.sh --with-config  # also install the model config template
```

Restart your ZCode session. Uninstall: `./uninstall.sh` (add
`--purge-config` to also remove the config).

The installer copies `skills/omzs-*` into `~/.agents/skills/`, symlinks
them into `~/.zcode/skills/` (matching this machine's existing layout), and
optionally installs the model config template. Override targets with
`AGENTS_SKILLS_DIR` / `ZCODE_SKILLS_DIR`.

## Model config (optional)

**No config = every role inherits the session model; it just works.** To pin
models per role, copy `config.example.json` to
`~/.agents/oh-my-zcode-slim.json` and edit:

```json
{
  "preset": "custom",
  "presets": {
    "custom": {
      "explorer":  { "model": "zhipu/glm-4.7-flash" },
      "oracle":    { "model": "zhipu/glm-4.7" },
      "fixer":     { "model": "zhipu/glm-4.7" }
    }
  }
}
```

`"model": null` (or no file at all) = inherit the session model. Note: if
ZCode subagents don't support per-agent model selection yet, these fields
are ignored gracefully; the file doubles as documentation of intent until
the host supports it.

## Usage

- **Automatic**: just start a non-trivial task; the main agent loads
  `omzs-dispatch` and orchestrates on its own.
- **Explicit**: say "orchestrate this" / "run this big refactor with the
  deepwork workflow".

## Design trade-offs (vs oh-my-opencode-slim)

Dropped: runtime preset switching, council multi-model arbitration, the
desktop companion, multiplexer panes, AST tooling, background wake
scheduling. Kept: the minimal viable core — roles + routing contract +
permission boundaries. Rationale: ZCode's extension points (the Agent tool,
the skill system) map naturally to the core; the rest is OpenCode-specific
periphery.

## Acknowledgments

- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) —
  MIT License, Copyright (c) 2025 alvinunreal. This project borrows heavily
  from its agent prompt design and routing philosophy.

## License

MIT — see [LICENSE](LICENSE) (includes the original author's copyright
notice) and [NOTICE](NOTICE).
