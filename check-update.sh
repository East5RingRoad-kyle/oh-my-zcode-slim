#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Check whether a newer oh-my-zcode-slim release is available.
# Works for both git clones and plain directory copies (no .git needed).
#
# Usage:
#   ./check-update.sh
#   OMZS_REPO=owner/repo ./check-update.sh   # override upstream for forks
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$HERE/VERSION"

LOCAL_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE" 2>/dev/null || true)"
if [[ -z "$LOCAL_VERSION" ]]; then
  echo "ERROR: VERSION file missing in $HERE" >&2
  exit 1
fi

# Resolve upstream owner/repo: env override > git remote > none.
REPO=""
if [[ -n "${OMZS_REPO:-}" ]]; then
  REPO="$OMZS_REPO"
else
  url="$(git -C "$HERE" config --get remote.origin.url 2>/dev/null || true)"
  if [[ "$url" == *github.com* ]]; then
    path="${url#*github.com}"
    path="${path#:}"   # strip ":" from git@github.com:owner/repo
    path="${path#/}"   # strip "/" from https://github.com/owner/repo
    path="${path%.git}" # strip trailing .git
    path="${path%/}"    # strip trailing slash
    [[ "$path" == */* ]] && REPO="$path"
  fi
fi

if [[ -z "$REPO" ]]; then
  echo "cannot determine upstream (no git remote, OMZS_REPO unset)"
  echo "set OMZS_REPO=owner/repo to enable update checks"
  exit 0
fi

REMOTE_VERSION="$(curl -fsSL --max-time 10 "https://raw.githubusercontent.com/$REPO/main/VERSION" 2>/dev/null | tr -d '[:space:]' || true)"

if [[ -z "$REMOTE_VERSION" ]]; then
  echo "could not reach upstream $REPO (offline or repo not public?)"
  exit 0
fi

if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
  echo "up to date ($LOCAL_VERSION)"
else
  echo "new version available: $REMOTE_VERSION (you have $LOCAL_VERSION)"
  echo "update: pull or re-copy the repo, then run ./install.sh"
fi
