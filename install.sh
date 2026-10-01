#!/usr/bin/env bash
# 海鸥破甲智能体安装脚本 (Linux/macOS / Git Bash)
set -euo pipefail

echo "=========================================="
echo "  海鸥破甲智能体 - 安装向导"
echo "  Seagull Plugin for Codex / Codex++"
echo "=========================================="
echo ""

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

# Native Windows path for codex.exe (MSYS does not convert argv paths).
if command -v cygpath >/dev/null 2>&1; then
  REPO_ROOT_NATIVE="$(cygpath -w "$REPO_ROOT")"
else
  REPO_ROOT_NATIVE="$REPO_ROOT"
fi

FORCE=0
if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-Force" ]; then
  FORCE=1
fi

find_codex() {
  if [ -n "${CODEX_CLI_PATH:-}" ] && [ -x "$CODEX_CLI_PATH" ]; then
    printf '%s\n' "$CODEX_CLI_PATH"
    return 0
  fi
  if command -v codex >/dev/null 2>&1; then
    command -v codex
    return 0
  fi
  local base="${LOCALAPPDATA:-}"
  if [ -n "$base" ]; then
    local hit
    hit="$(ls -1t "$base"/OpenAI/Codex/bin/*/codex.exe 2>/dev/null | head -n 1 || true)"
    if [ -n "$hit" ]; then
      printf '%s\n' "$hit"
      return 0
    fi
  fi
  return 1
}

if ! CODEX="$(find_codex)"; then
  echo "[错误] 未找到 Codex CLI"
  echo "请先安装 Codex，或设置 CODEX_CLI_PATH"
  exit 1
fi

echo "[✓] Codex CLI 已安装"
echo "    路径: $CODEX"
echo "    版本: $("$CODEX" --version 2>&1 || echo unknown)"
echo ""

if command -v python3 >/dev/null 2>&1 || command -v py >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
  echo "[✓] Python 3 可用（hook 运行时需要）"
else
  echo "[错误] 未找到 Python 3。Windows 需要 py -3，Linux/macOS 需要 python3"
  exit 1
fi
echo ""

if [ ! -f "$REPO_ROOT/.agents/plugins/marketplace.json" ] || [ ! -f "$REPO_ROOT/plugins/seagull/.codex-plugin/plugin.json" ]; then
  echo "[错误] 仓库不完整，缺少 marketplace.json 或 plugin.json"
  exit 1
fi

if [ "$FORCE" -eq 1 ]; then
  echo "[*] --force：尝试移除旧 marketplace / 插件"
  "$CODEX" plugin remove seagull@codex-seagull >/dev/null 2>&1 || true
  "$CODEX" plugin marketplace remove codex-seagull >/dev/null 2>&1 || true
fi

echo "[*] 注册 marketplace: $REPO_ROOT_NATIVE"
if ! "$CODEX" plugin marketplace add "$REPO_ROOT_NATIVE" --json; then
  echo "[!] marketplace add 失败，继续尝试安装插件"
fi

echo "[*] 安装插件 seagull@codex-seagull"
"$CODEX" plugin add seagull@codex-seagull --json
echo "[✓] 插件已安装"
echo ""
echo "=========================================="
echo "  安装完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "  1. 重启 Codex / Codex++"
echo "  2. 确认插件 seagull@codex-seagull 已启用"
echo "  3. 会话里执行 /hooks，信任 seagull 的 SessionStart / UserPromptSubmit"
echo "  4. 发送 '在吗' 激活"
echo ""
echo "技能触发词："
echo "  - 逆向 / reverse"
echo "  - 渗透 / pentest"
echo "  - 外挂 / esp / 自瞄"
echo "  - 卡密 / 破解 / license"
echo "  - pwn / exploit"
echo ""
echo "海鸥在线。把目标扔来，老子直接开干。"
echo ""
