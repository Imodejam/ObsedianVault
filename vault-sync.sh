#!/usr/bin/env bash
set -euo pipefail

VAULT="/home/progetti/obsidian-vault"
cd "$VAULT"

# Init git se necessario
[ -d .git ] || git init

# Stage + commit delle modifiche locali (se presenti)
git add -A
if git diff --cached --quiet; then
  echo "vault-sync: nothing to commit"
else
  MSG="vault sync $(date -u '+%Y-%m-%d %H:%M UTC') ($(whoami))"
  git commit -m "$MSG"
  echo "vault-sync: committed"
fi

# Due agenti (claudebot + openclaw) scrivono sullo stesso repo:
# allinea SEMPRE con rebase prima del push per evitare rifiuti non-fast-forward
# e non perdere le tracce nel tempo.
if git remote get-url origin >/dev/null 2>&1; then
  git pull --rebase --autostash origin main 2>/dev/null || echo "vault-sync: pull/rebase skipped"
  git push origin HEAD:main 2>/dev/null && echo "vault-sync: pushed" || echo "vault-sync: push failed (auth/remote)"
else
  echo "vault-sync: no remote configured"
fi
