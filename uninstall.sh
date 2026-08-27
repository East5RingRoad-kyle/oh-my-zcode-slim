#!/usr/bin/env bash
#
# oh-my-zcode-slim uninstaller.
# Removes the specialist agent files and orchestrator skills. Leaves
# .omzs-backup.* files and everything else untouched.
#
# Usage:
#   ./uninstall.sh                     # user-scope removal
#   ./uninstall.sh --scope workspace   # remove <cwd>/.zcode/agents copies
set -euo pipefail

ZCODE_HOME="${ZCODE_HOME:-$HOME/.zcode}"
AGENTS_SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
ZCODE_SKILLS_DIR="${ZCODE_SKILLS_DIR:-$HOME/.zcode/skills}"
SCOPE="user"
[[ "${1:-}" == "--scope" && "${2:-}" == "workspace" ]] && SCOPE="workspace"

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

for agent in "${AGENT_FILES[@]}"; do
  f="$AGENTS_MD_DIR/$agent.md"
  if [[ -e "$f" ]]; then
    rm -f "$f"
    echo "removed   $f"
  fi
done

for skill in "${SKILLS[@]}"; do
  for dir in "$AGENTS_SKILLS_DIR" "$ZCODE_SKILLS_DIR"; do
    target="$dir/$skill"
    if [[ -L "$target" || -d "$target" ]]; then
      rm -rf "$target"
      echo "removed   $target"
    fi
  done
done

echo "Done. (Any $AGENTS_MD_DIR/*.omzs-backup.* files were kept.)"
