#!/usr/bin/env bash
#
# oh-my-zcode-slim installer.
#
# 1. Registers 5 specialist subagents (explorer/oracle/librarian/fixer/designer)
#    as native ZCode agents: ~/.zcode/agents/<name>.md
# 2. Installs orchestrator skills (omzs-dispatch, omzs-deepwork) into
#    ~/.agents/skills/ and symlinks them into ~/.zcode/skills/.
#
# Usage:
#   ./install.sh                     # install everything
#   ./install.sh --scope workspace   # agents into <cwd>/.zcode/agents instead
#   ZCODE_HOME=... ./install.sh      # override ~/.zcode
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

echo "oh-my-zcode-slim installer"
echo "  repo:            $HERE"
echo "  agents ($SCOPE): $AGENTS_MD_DIR"
echo "  agents skills:   $AGENTS_SKILLS_DIR"
echo "  zcode skills:    $ZCODE_SKILLS_DIR"
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
  if [[ -f "$dst" && ! -L "$dst" ]] && ! cmp -s "$dst" "$src"; then
    # real file with local changes (e.g. edited via the ZCode settings UI).
    # Back it up; unchanged copies are overwritten silently.
    backup="$dst.omzs-backup.$(date +%Y%m%d%H%M%S)"
    cp "$dst" "$backup"
    echo "WARNING: $dst had local changes; backed up to $backup" >&2
    echo "         before overwriting (edit agents/$agent.md in the repo to make changes stick)." >&2
  fi
  rm -f "$dst"
  cp "$src" "$dst"
  echo "installed  $dst"
done

# --- 2. orchestrator skills ---
mkdir -p "$AGENTS_SKILLS_DIR" "$ZCODE_SKILLS_DIR"
for skill in "${SKILLS[@]}"; do
  src="$HERE/skills/$skill"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "ERROR: $src/SKILL.md not found (repo corrupted?)" >&2
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
  # relative link when both dirs share the home prefix; absolute otherwise
  case "$AGENTS_SKILLS_DIR/$skill" in
    "$HOME"/*)
      rel="$(cd "$ZCODE_SKILLS_DIR" && printf '%s/%s' "${AGENTS_SKILLS_DIR#$HOME/}" "$skill")"
      ln -s "../../${rel%%/*}/$(dirname "${rel#*/}")/$skill" "$link" 2>/dev/null \
        || ln -s "$AGENTS_SKILLS_DIR/$skill" "$link"
      ;;
    *)
      ln -s "$AGENTS_SKILLS_DIR/$skill" "$link"
      ;;
  esac
  echo "symlinked $link -> $AGENTS_SKILLS_DIR/$skill"
done

echo
echo "Done. Restart your ZCode session."
echo "The nine roles appear in Settings > Subagents; per-agent model and"
echo "thought level can be set there per agent (default: inherit session model)."
