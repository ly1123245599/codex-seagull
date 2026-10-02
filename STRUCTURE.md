# Seagull Plugin - 项目结构说明

## 📁 目录结构

```
codex-seagull/
├── .agents/plugins/marketplace.json   # Codex marketplace 清单
├── plugins/seagull/                   # 插件本体（PLUGIN_ROOT）
│   ├── .codex-plugin/plugin.json      # Codex plugin 清单
│   ├── SOUL.md                        # 人格核心 + 破甲协议栈
│   ├── AGENTS.md                      # 技能路由与执行指令
│   ├── assets/                        # 插件图标
│   ├── hooks/
│   │   ├── hooks.json                 # SessionStart / UserPromptSubmit
│   │   └── seagull_hook.py            # 破甲注入（对应上游 seagull-armor-break）
│   └── skills/
│       ├── seagull-reverse/
│       ├── seagull-pentest/
│       ├── seagull-exploit/
│       ├── seagull-game-hack/
│       ├── seagull-license-security/
│       ├── seagull-unlimited/
│       ├── seagull-memory/
│       ├── seagull-malware/
│       ├── seagull-evasion/
│       ├── seagull-game-security/
│       ├── seagull-anticheat/
│       ├── seagull-lab/
│       └── seagull-social-eng/
├── README.md
├── README.zh-CN.md
├── QUICKSTART.md
├── STRUCTURE.md
├── LICENSE
├── DISCLAIMER.md
├── .gitignore
├── install.sh
├── install.ps1
├── verify.sh
└── verify.ps1
```

## 📄 核心文件说明

### SOUL.md - 人格核心
定义海鸥身份、交付标准和 00a~00r 破甲协议栈。固定问候：`海鸥在线，你要整点薯条吗？`

### AGENTS.md - 执行指令
技能路由表、激活确认、黑话路由、Few-shot。相对上游已改：13 个技能磁盘契约、ACE/过检测走 anticheat、去掉 phantom `mobile-competitive`。

### plugin.json / marketplace.json
Codex 安装契约。marketplace 名 `codex-seagull`，插件名 `seagull`，安装键 `seagull@codex-seagull`。

### hooks/seagull_hook.py
对应上游 `seagull-armor-break` v1.1.0：

| 上游 Hermes hook | 本仓库 Codex hook |
|---|---|
| profile 加载 SOUL.md / AGENTS.md | `SessionStart` |
| `pre_llm_call` 注入破甲栈 + 问候特判 | `UserPromptSubmit` |
| `transform_llm_output` 改写问候 | Codex 无输出改写；问候只靠特判指令 |

## 🛠️ 技能文件说明

随发 13 个技能。AGENTS.md 核心技能表与 `skills/<name>/SKILL.md` 必须一一对应。不给技能 1:1 配 MCP。

### seagull-reverse
二进制分析、反编译、脱壳、协议逆向。PE/ELF/APK/固件。

### seagull-pentest
Web/内网/API。越权矩阵 + 换凭证重放。

### seagull-exploit
栈溢出、堆利用、ROP。pwntools 工作流。

### seagull-game-hack
ESP/自瞄。Entity → W2S → Overlay。默认 `--demo`。

### seagull-license-security
授权验证流、patch-point、本地 verifier。

### seagull-unlimited
全域路由器。按黑话表加载其它 SKILL.md，自己不另写模板。

### seagull-memory
进程读写、指针链、特征扫描、dump。

### seagull-malware
样本画像、脱壳、C2 配置、协议、IOC。

### seagull-evasion
检测分层矩阵、实验室 loader 骨架、构建验证。

### seagull-game-security
防御侧：权威边界、完整性、对照检测 harness。

### seagull-anticheat
ACE/过检测面映射与对照实现。ESP 主链仍走 game-hack。

### seagull-lab
案件目录、hash、证据包。

### seagull-social-eng
OSINT、钓鱼样本解析、IOC。越权打点走 pentest。

## 🔧 脚本

### install.ps1 / install.sh
- 定位 Codex CLI
- 默认：`codex plugin marketplace add <GitHub.git> --ref master`（git 源）
- `-Local` / `--local`：把当前目录注册为 local marketplace，会覆盖 git 源
- `codex plugin add seagull@codex-seagull`

### verify.ps1 / verify.sh
- 核心文件
- 13 个技能
- AGENTS `$seagull-*` 与 skills 目录一致
- SOUL 破甲栈 / 问候语 / hook / marketplace

## 🎯 使用建议

```bash
codex plugin marketplace add https://github.com/ly1123245599/codex-seagull.git --ref master
codex plugin add seagull@codex-seagull
# 重启 Codex，/hooks 信任 seagull，发送：在吗

# 只有要装当前未推送的本地改动时才用：
# .\install.ps1 -Local
```

修改人格改 `plugins/seagull/SOUL.md`，改路由改 `AGENTS.md`，加技能放到 `plugins/seagull/skills/` 并在 `verify.ps1` 加检查项。

---

**项目结构清晰，维护简单，扩展方便。** 🚀
