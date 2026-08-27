#!/usr/bin/env bash
#
# oh-my-zcode-slim installer.
# Copies the skills into ~/.agents/skills/ and symlinks them into
# ~/.zcode/skills/ (matching the layout this machine already uses).
# Optional: copy config.example.json to ~/.agents/oh-my-zcode-slim.json.
#
# Usage:
#   ./install.sh              # install skills
#   ./install.sh --with-config  # also install the editable model config
#   ZCODE_SKILLS_DIR=... ./install.sh  # override target
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AGENTS_SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
ZCODE_SKILLS_DIR="${ZCODE_SKILLS_DIR:-$HOME/.zcode/skills}"
WITH_CONFIG=0
[[ "${1:-}" == "--with-config" ]] && WITH_CONFIG=1

SKILLS=(
  omzs-dispatch
  omzs-explorer
  omzs-oracle
  omzs-librarian
  omzs-fixer
  omzs-designer
  omzs-deepwork
)

echo "oh-my-zcode-slim installer"
echo "  repo:            $HERE"
echo "  agents skills:   $AGENTS_SKILLS_DIR"
echo "  zcode skills:    $ZCODE_SKILLS_DIR"
echo

mkdir -p "$AGENTS_SKILLS_DIR" "$ZCODE_SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  src="$HERE/skills/$skill"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "ERROR: $src/SKILL.md not found (repo corrupted?)" >&2
    exit 1
  fi

  # 1. copy the real files into ~/.agents/skills/
  rm -rf "$AGENTS_SKILLS_DIR/$skill"
  cp -R "$src" "$AGENTS_SKILLS_DIR/$skill"
  echo "installed  ~/.agents/skills/$skill"

  # 2. symlink into ~/.zcode/skills/ (same convention as existing skills).
  #    compute the relative path so it works regardless of absolute location.
  link="$ZCODE_SKILLS_DIR/$skill"
  if [[ -L "$link" || -e "$link" ]]; then
    rm -rf "$link"
  fi
  ln -s "$(python3 -c "import os,sys; print(os.path.relpath('$AGENTS_SKILLS_DIR/$skill', '$ZCODE_SKILLS_DIR'))")" "$link"
  echo "symlinked ~/.zcode/skills/$skill -> ~/.agents/skills/$skill"
done

# 3. optional model config
if [[ "$WITH_CONFIG" -eq 1 ]]; then
  cfg="$HOME/.agents/oh-my-zcode-slim.json"
  if [[ -e "$cfg" ]]; then
    echo "config    $cfg already exists, left untouched"
  else
    cp "$HERE/config.example.json" "$cfg"
    echo "config    copied template to $cfg (edit models there; null = inherit)"
  fi
fi

echo
echo "Done. Restart your ZCode session and the omzs-* skills will be available."
echo "Optional: ./install.sh --with-config   to install the model config template."
