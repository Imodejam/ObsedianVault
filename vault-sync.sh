#!/usr/bin/env bash
set -euo pipefail

VAULT="/home/progetti/obsidian-vault"
cd "$VAULT"

# Init git se necessario
[ -d .git ] || git init

# Stage, commit, push
git add -A
if git diff --cached --quiet; then
  echo "vault-sync: nothing to commit"
else
  MSG="vault sync $(date -u '+%Y-%m-%d %H:%M UTC')"
  git commit -m "$MSG"
  git push 2>/dev/null || echo "vault-sync: push failed (no remote or auth issue)"
  echo "vault-sync: committed and pushed"
fi
