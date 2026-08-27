#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# oh-my-zcode-slim installer.
#
# 1. Registers 9 team subagents (explorer/oracle/librarian/fixer/designer/
#    observer/council/councillor-alpha/councillor-beta) as native ZCode
#    agents: <agents-dir>/<name>.md
# 2. Installs orchestrator skills (omzs-dispatch, omzs-deepwork) into
#    ~/.agents/skills/ and symlinks them into ~/.zcode/skills/.
#
# Usage:
#   ./install.sh                     # install everything
#   ./install.sh --scope workspace   # agents into <cwd>/.zcode/agents instead
#   ZCODE_HOME=... ./install.sh      # override ~/.zcode (agents only; if you
#                                    # set ZCode's storage.dir, point this at it)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZCODE_HOME="${ZCODE_HOME:-$HOME/.zcode}"
AGENTS_SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
ZCODE_SKILLS_DIR="${ZCODE_SKILLS_DIR:-$HOME/.zcode/skills}"

usage() {
  echo "usage: ./install.sh [--scope workspace]" >&2
  exit 1
}

SCOPE="user"
[[ $# -gt 0 ]] && {
  [[ "$1" == "--scope" && "${2:-}" == "workspace" ]] || usage
  SCOPE="workspace"
}

SKILLS=(
  omzs-dispatch
  omzs-deepwork
)
AGENT_FILES=(
  explorer
  oracle
  librarian
  fixer
  designer
  observer
  council
  councillor-alpha
  councillor-beta
)

if [[ "$SCOPE" == "workspace" ]]; then
  AGENTS_MD_DIR="$PWD/.zcode/agents"
else
  AGENTS_MD_DIR="$ZCODE_HOME/agents"
fi

VERSION_FILE="$HERE/VERSION"
NEW_VERSION="$(cat "$VERSION_FILE" 2>/dev/null | tr -d '[:space:]' || true)"
NEW_VERSION="${NEW_VERSION:-unknown}"
STAMP_FILE="$AGENTS_MD_DIR/.omzs-version"
OLD_VERSION="$(cat "$STAMP_FILE" 2>/dev/null | tr -d '[:space:]' || true)"

echo "oh-my-zcode-slim installer"
echo "  repo:            $HERE"
echo "  agents ($SCOPE): $AGENTS_MD_DIR"
echo "  agents skills:   $AGENTS_SKILLS_DIR"
echo "  zcode skills:    $ZCODE_SKILLS_DIR"
if [[ -n "$OLD_VERSION" && "$OLD_VERSION" != "$NEW_VERSION" ]]; then
  echo "  version:         $OLD_VERSION -> $NEW_VERSION (upgrade)"
elif [[ -n "$OLD_VERSION" ]]; then
  echo "  version:         $NEW_VERSION (reinstall, no change)"
else
  echo "  version:         $NEW_VERSION (fresh install)"
fi
echo

# --- 1. native subagents ---
mkdir -p "$AGENTS_MD_DIR"
for agent in "${AGENT_FILES[@]}"; do
  src="$HERE/agents/$agent.md"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: $src not found (repo corrupted?)" >&2
    exit 1
  fi
  dst="$AGENTS_MD_DIR/$agent.md"
  if [[ -f "$dst" ]] && ! cmp -s "$dst" "$src"; then
    # real file with local changes (e.g. edited via the ZCode settings UI).
    # Back it up; unchanged copies are overwritten silently.
    backup="$dst.omzs-backup.$(date +%Y%m%d%H%M%S)"
    while [[ -e "$backup" ]]; do backup="$backup.$RANDOM"; done
    cp "$dst" "$backup"
    echo "WARNING: $dst had local changes; backed up to $backup" >&2
    echo "         (edit agents/$agent.md in the repo to make changes stick)" >&2
  fi
  rm -f "$dst"
  cp "$src" "$dst"
  echo "installed  $dst"
done

# --- 2. orchestrator skills ---
mkdir -p "$AGENTS_SKILLS_DIR" "$ZCODE_SKILLS_DIR"

# same-dir guard: cp then rm -rf on identical paths would delete the copy
a="$(cd "$AGENTS_SKILLS_DIR" && pwd)"; z="$(cd "$ZCODE_SKILLS_DIR" && pwd)"
if [[ "$a" == "$z" ]]; then
  echo "ERROR: ZCODE_SKILLS_DIR and AGENTS_SKILLS_DIR resolve to the same directory ($a)." >&2
  exit 1
fi

for skill in "${SKILLS[@]}"; do
  src="$HERE/skills/$skill"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "ERROR: $src/SKILL.md not found (repo corrupted? re-run installs what's missing)" >&2
    exit 1
  fi
  if [[ -d "$AGENTS_SKILLS_DIR/$skill" && ! -L "$ZCODE_SKILLS_DIR/$skill" ]]; then
    echo "note:     $AGENTS_SKILLS_DIR/$skill exists; overwriting (edit the repo and reinstall instead)"
  fi
  rm -rf "$AGENTS_SKILLS_DIR/$skill"
  cp -R "$src" "$AGENTS_SKILLS_DIR/$skill"
  echo "installed  $AGENTS_SKILLS_DIR/$skill"

  link="$ZCODE_SKILLS_DIR/$skill"
  rm -rf "$link"
  ln -s "$AGENTS_SKILLS_DIR/$skill" "$link"
  if [[ ! -e "$link" ]]; then
    echo "ERROR: symlink $link does not resolve" >&2
    exit 1
  fi
  echo "symlinked $link -> $AGENTS_SKILLS_DIR/$skill"
done

echo
echo "Done. Restart your ZCode session (new session, or relaunch the app)."
echo "The nine roles appear in Settings > Subagents; per-agent model and"
echo "thought level can be set there per agent (default: inherit session model)."
echo "Quick check: new session -> type / -> omzs-dispatch should be listed."
printf '%s\n' "$NEW_VERSION" > "$STAMP_FILE"
