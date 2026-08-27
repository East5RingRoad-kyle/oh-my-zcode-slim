---
name: omzs-deepwork
description: >
  Heavy multi-phase workflow for large, high-risk changes: phase file,
  per-phase oracle review gates (first review + max two re-reviews), and a
  focused commit per completed phase. Do NOT activate for routine
  multi-file changes; only for work where a wrong step is expensive.
---

# Deepwork — phased execution for high-risk work

Use this workflow when a change is large, high-risk, or multi-phase — where
"just start editing" would be reckless. Do not activate for routine
multi-file changes.

## Setup

1. Create a phase file `.slim/deepwork/<slug>.md` in the repo root
   (mkdir -p first). It is the single source of truth for progress.
2. Split the work into phases, each independently verifiable. Write them
   into the phase file: goal, scope, files touched, verification command,
   and a status field (`pending | in-progress | review | done`).
3. Before phase 1, run a verification-planning pass: decide what evidence
   will count as "this phase works" — commands, expected output, manual
   checks. Write it into each phase's `verification:` field.

## Per-phase loop

1. Mark the phase `in-progress` in the phase file.
2. Dispatch the implementation as one bounded lane (typically @fixer, or
   @designer for UI phases), inlining the playbook as usual.
3. When the specialist returns, mark the phase `review`.
4. **Review gate**: dispatch @oracle with the phase diff and the phase's
   verification plan. Oracle verdicts:
   - `approve` → mark `done`, make a focused commit for the phase, proceed.
   - `reject (fixable)` → dispatch the fix, then re-review. **Budget: the
     initial review + at most 2 re-reviews per phase.** Spend re-reviews
     sparingly — batch fixes before asking again.
   - `reject (fundamental)` → stop, surface to the user with oracle's
     reasoning. Do not burn re-reviews on a wrong plan.
5. Update the phase file after every state change (it must survive a
   session restart).

## Rules

- One phase in flight at a time; read-only recon (explorer) may run in
  parallel with any phase.
- Never skip a review gate. Never exceed the review budget — if consensus
  isn't reached by the last re-review, stop and report to the user.
- Phase commits: conventional, focused, referencing the phase slug.
- If the session is interrupted, resume from the phase file, not from
  memory.

## Phase file format

```markdown
# Deepwork: <slug>

Goal: <one sentence>
Verification plan: <what evidence counts, per phase>

## Phase 1 — <name>
status: done
scope: <files/areas>
verification: <command + expected>
review: <oracle verdict summary>

## Phase 2 — ...
```
