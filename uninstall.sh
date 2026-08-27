#!/usr/bin/env bash
#
# oh-my-zcode-slim uninstaller. Removes the omzs-* skills and (optionally)
# the model config. Leaves everything else untouched.
#
# Usage:
#   ./uninstall.sh              # remove skills only
#   ./uninstall.sh --purge-config  # also remove ~/.agents/oh-my-zcode-slim.json
set -euo pipefail

AGENTS_SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
ZCODE_SKILLS_DIR="${ZCODE_SKILLS_DIR:-$HOME/.zcode/skills}"
PURGE=0
[[ "${1:-}" == "--purge-config" ]] && PURGE=1

SKILLS=(
  omzs-dispatch
  omzs-explorer
  omzs-oracle
  omzs-librarian
  omzs-fixer
  omzs-designer
  omzs-deepwork
)

for skill in "${SKILLS[@]}"; do
  for dir in "$AGENTS_SKILLS_DIR" "$ZCODE_SKILLS_DIR"; do
    target="$dir/$skill"
    if [[ -L "$target" || -d "$target" ]]; then
      rm -rf "$target"
      echo "removed   $target"
    fi
  done
done

if [[ "$PURGE" -eq 1 ]]; then
  cfg="$HOME/.agents/oh-my-zcode-slim.json"
  if [[ -e "$cfg" ]]; then
    rm -f "$cfg"
    echo "removed   $cfg"
  fi
fi

echo "Done."
