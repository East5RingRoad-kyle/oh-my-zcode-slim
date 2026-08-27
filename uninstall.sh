#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# oh-my-zcode-slim uninstaller.
# Removes the team agent files and orchestrator skills. Only removes files
# carrying our marker comment; leaves user-created files, backups, and
# everything else untouched.
#
# Usage:
#   ./uninstall.sh                     # user scope (~/.zcode/agents)
#   ./uninstall.sh --scope workspace   # remove $PWD/.zcode/agents copies
#   ./uninstall.sh --all               # both scopes + skills
set -euo pipefail

ZCODE_HOME="${ZCODE_HOME:-$HOME/.zcode}"
AGENTS_SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
ZCODE_SKILLS_DIR="${ZCODE_SKILLS_DIR:-$HOME/.zcode/skills}"

usage() {
  echo "usage: ./uninstall.sh [--scope workspace | --all]" >&2
  exit 1
}

MODE="user"
[[ $# -gt 0 ]] && {
  case "$1" in
    --scope) [[ "${2:-}" == "workspace" ]] || usage; MODE="workspace" ;;
    --all)   MODE="all" ;;
    *)       usage ;;
  esac
}

MARKER='oh-my-zcode-slim'

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

USER_AGENTS_DIR="$ZCODE_HOME/agents"
WS_AGENTS_DIR="$PWD/.zcode/agents"

remove_agents() {
  local dir="$1" removed=0
  if [[ ! -d "$dir" ]]; then
    echo "note:     no omzs agents found under $dir (wrong scope or not installed)" >&2
    return 0
  fi
  for agent in "${AGENT_FILES[@]}"; do
    f="$dir/$agent.md"
    if [[ -f "$f" ]] && grep -q "$MARKER" "$f" 2>/dev/null; then
      rm -f "$f" && removed=$((removed+1)) && echo "removed   $f"
    elif [[ -e "$f" ]]; then
      echo "kept      $f (no $MARKER marker — not ours or locally edited)" >&2
    fi
  done
  if [[ $removed -eq 0 ]]; then
    echo "note:     no omzs agents found under $dir (installed with --scope workspace?)" >&2
  fi
}

remove_skills() {
  for skill in "${SKILLS[@]}"; do
    for dir in "$AGENTS_SKILLS_DIR" "$ZCODE_SKILLS_DIR"; do
      target="$dir/$skill"
      if [[ -L "$target" || -d "$target" ]]; then
        rm -rf "$target"
        echo "removed   $target"
      fi
    done
  done
}

case "$MODE" in
  user)      remove_agents "$USER_AGENTS_DIR"; remove_skills ;;
  workspace) remove_agents "$WS_AGENTS_DIR"
             echo "note:     skills were installed globally; removing them globally too" >&2
             remove_skills ;;
  all)       remove_agents "$USER_AGENTS_DIR"; remove_agents "$WS_AGENTS_DIR"; remove_skills ;;
esac

echo "Done. (Any *.omzs-backup.* files were kept.)"
