# Contributing

Thanks for helping with oh-my-zcode-slim. This project is deliberately
small: a set of Markdown subagents, two orchestrator skills, and a few
bash helpers. Keep changes in that spirit.

## No-code ways to help

- Star the repo so ZCode users can find it.
- Share the repo in ZCode user groups or communities.
- Open issues for missing roles, routing gaps, broken docs, or
  marketplace install problems.

## Reporting issues

Before opening an issue, search existing issues and discussions.

For bug reports, include:

- What you ran (install command, ZCode version, OS).
- What you expected to happen.
- What actually happened.
- Relevant log output or error text.

For feature requests, describe the workflow you want and why the current
routing table or permission model does not cover it.

## Development workflow

1. Fork the repo and create a branch.
2. Keep changes scoped: agents under `agents/`, skills under `skills/`,
   installer scripts at the repo root, plugin metadata under `.zcode-plugin/`.
3. Update `CHANGELOG.md` under `## [Unreleased]` when behavior changes.
4. If the release version changes, update all three places consistently:
   - `VERSION`
   - `marketplace.json` -> `.plugins[0].version`
   - `.zcode-plugin/plugin.json` -> `.version`
5. Enable the bundled commit hook locally:
   ```bash
   git config core.hooksPath .githooks
   ```
6. Commit with Conventional Commits:
   ```text
   <type>(<optional scope>): <description>
   ```
   Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`,
   `test`, `build`, `ci`, `chore`, `revert`.
7. Open a pull request. CI validates JSON manifests, version consistency,
   and the required agent/skill files.

## Adding or changing a subagent

- Add or edit `agents/<name>.md`.
- Keep the frontmatter fields ZCode uses: `name`, `description`, `color`,
  `tools`, `disallowedTools`, `permissionMode` (where applicable), and
  `model`.
- Update the routing table in `skills/omzs-dispatch/SKILL.md`.
- Update the README role table and, if the team size changes, the
  self-test and any installer lists that enumerate roles.
- Do not let a read-only role acquire write tools, and do not let a
  leaf role gain dispatch tools.

## Releasing

- Bump `VERSION` and keep the version metadata in sync.
- Update `CHANGELOG.md` with a dated release section.
- Create a GitHub release tagged `v<version>`.
- The CI validation job will catch version drift.
