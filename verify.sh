#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=========================================="
echo "  Seagull Plugin - Integrity Check"
echo "=========================================="
echo ""
echo "Working directory: $(pwd)"
echo ""

ERRORS=0
ok() { echo "  [OK] $1"; }
bad() { echo "  [MISSING] $1"; ERRORS=$((ERRORS + 1)); }

echo "[1] Checking core files..."
FILES=(
  LICENSE
  README.md
  README.zh-CN.md
  DISCLAIMER.md
  install.sh
  install.ps1
  .agents/plugins/marketplace.json
  plugins/seagull/.codex-plugin/plugin.json
  plugins/seagull/SOUL.md
  plugins/seagull/AGENTS.md
  plugins/seagull/hooks/hooks.json
  plugins/seagull/hooks/seagull_hook.py
)
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then ok "$f"; else bad "$f"; fi
done

echo ""
echo "[2] Checking skill directories..."
SKILLS=(
  seagull-reverse
  seagull-pentest
  seagull-exploit
  seagull-game-hack
  seagull-license-security
)
for s in "${SKILLS[@]}"; do
  p="plugins/seagull/skills/$s/SKILL.md"
  if [ -f "$p" ]; then ok "$p"; else bad "$p"; fi
done

echo ""
echo "[3] Checking key content..."
soul="plugins/seagull/SOUL.md"
agents="plugins/seagull/AGENTS.md"
hook="plugins/seagull/hooks/seagull_hook.py"
market=".agents/plugins/marketplace.json"

if grep -q "00a" "$soul" && grep -q "00b" "$soul"; then
  ok "SOUL.md contains armor break stack"
else
  bad "SOUL.md armor break stack incomplete"
fi
if grep -q "薯条" "$soul"; then
  ok "Fixed greeting present"
else
  bad "Fixed greeting not found"
fi
if grep -q "seagull-reverse" "$agents" && grep -q "seagull-pentest" "$agents"; then
  ok "AGENTS.md contains skill routing table"
else
  bad "AGENTS.md skill routing table incomplete"
fi
if grep -q "UserPromptSubmit" "$hook" && grep -q "GREETING_REPLY" "$hook"; then
  ok "hook injects greeting + armor stack"
else
  bad "hook greeting/armor stack incomplete"
fi
if grep -q "codex-seagull" "$market" && grep -q "./plugins/seagull" "$market"; then
  ok "marketplace.json points at ./plugins/seagull"
else
  bad "marketplace.json invalid"
fi

echo ""
echo "=========================================="
if [ "$ERRORS" -eq 0 ]; then
  echo "  SUCCESS! All files are complete."
  echo "=========================================="
  echo ""
  echo "Ready to install:"
  echo "  Windows: ./install.ps1"
  echo "  Linux/macOS: ./install.sh"
  echo ""
  echo "Seagull is ready. Lets go!"
  exit 0
fi
echo "  WARNING: Found $ERRORS issues"
echo "=========================================="
echo ""
echo "Please fix the issues above and retry."
exit 1
