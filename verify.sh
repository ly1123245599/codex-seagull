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
  seagull-unlimited
  seagull-reverse
  seagull-pentest
  seagull-exploit
  seagull-memory
  seagull-malware
  seagull-evasion
  seagull-game-hack
  seagull-game-security
  seagull-anticheat
  seagull-license-security
  seagull-lab
  seagull-social-eng
)
for s in "${SKILLS[@]}"; do
  p="plugins/seagull/skills/$s/SKILL.md"
  if [ -f "$p" ]; then ok "$p"; else bad "$p"; fi
done

disk_skills=$(ls -1 plugins/seagull/skills | sort)
listed=$(printf '%s\n' "${SKILLS[@]}" | sort)
if [ "$disk_skills" = "$listed" ]; then
  ok "skills/ directories match the 13-name list"
else
  bad "skills/ directories drift from the 13-name list"
fi

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
agent_names=$(grep -oE '\$seagull-[a-z0-9-]+' "$agents" | sed 's/^\$//' | sort -u)
if [ "$agent_names" = "$listed" ]; then
  ok "AGENTS.md \$seagull-* names match skill directories"
else
  bad "AGENTS.md skill names drift from skills/"
fi
if grep -q "mobile-competitive" "$agents"; then
  bad "AGENTS.md still routes a phantom skill name"
else
  ok "AGENTS.md has no phantom skill names"
fi
plugin="plugins/seagull/.codex-plugin/plugin.json"
if grep -q '"version": "1.2.0"' "$plugin" && ! grep -q "mcpServers" "$plugin"; then
  ok "plugin.json is 1.2.0 and has no MCP servers"
else
  bad "plugin.json version or MCP field wrong"
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
echo "[4] Hook smoke test..."
PLUGIN_ROOT_UNIX="$PWD/plugins/seagull"
HOOK_UNIX="$PLUGIN_ROOT_UNIX/hooks/seagull_hook.py"
if command -v cygpath >/dev/null 2>&1; then
  export PLUGIN_ROOT="$(cygpath -w "$PLUGIN_ROOT_UNIX")"
  HOOK="$(cygpath -w "$HOOK_UNIX")"
else
  export PLUGIN_ROOT="$PLUGIN_ROOT_UNIX"
  HOOK="$HOOK_UNIX"
fi
PAYLOAD='{"hook_event_name":"UserPromptSubmit","prompt":"ping"}'
if command -v py >/dev/null 2>&1; then
  PY=(py -3)
elif command -v python3 >/dev/null 2>&1; then
  PY=(python3)
elif command -v python >/dev/null 2>&1; then
  PY=(python)
else
  PY=()
fi
if [ "${#PY[@]}" -eq 0 ]; then
  bad "Python 3 not found (hook cannot run)"
else
  OUT="$(printf '%s' "$PAYLOAD" | "${PY[@]}" "$HOOK" 2>/dev/null || true)"
  if printf '%s' "$OUT" | grep -q "UNRESTRICTED_PARITY"; then
    ok "UserPromptSubmit injects armor stack"
  else
    bad "hook did not inject armor stack"
  fi
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
