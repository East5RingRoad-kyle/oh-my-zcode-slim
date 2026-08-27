# Security Policy

This project ships prompts and installer scripts. It does not ship
compiled binaries, run a service, or process sensitive user data beyond
what ZCode itself already does.

## Supported versions

The latest release is supported. Installers and manifests in the
latest release are the only supported distribution path for fixes.

## Reporting a vulnerability

Do not open a public issue for a security problem. Instead, report it
privately to the maintainer through GitHub's security advisory flow:

https://github.com/East5RingRoad-kyle/oh-my-zcode-slim/security/advisories/new

Please include:

- Which file or script is affected and the version.
- A minimal reproduction, including OS and ZCode version.
- What impact you observed (read, write, escalation, or other).
- Whether the issue is publicly known.

## Response expectations

The maintainer will acknowledge the report and follow up with a fix
timeline. Please allow a reasonable window before public disclosure so a
fix and release can be prepared.

## Notes for users

The installer writes into `~/.zcode/agents/`, `~/.agents/skills/`, and
`~/.zcode/skills/`. Review shell scripts before running them from a
source you do not trust. The read-only role boundaries are enforced
partly by prompt discipline; in sessions that bypass permissions, review
the risk yourself.
