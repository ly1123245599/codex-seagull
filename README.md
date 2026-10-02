# 海鸥破甲插件 Seagull Armor-Break Plugin

**基于 Codex Plugin 的 CTF/Red-team/Reverse/Pentest 全域插件**

> 通过插件式命令行安装，叠加在 Codex 之上，提供完整破甲能力。
>
> 人格与破甲栈来自 [laoshu666/hermes-seagull](https://github.com/laoshu666/hermes-seagull) v1.1.0。专业技能按 AGENTS 路由表随发 13 个 SKILL.md，不是上游那 5 个。使用前请阅读 [免责声明](./DISCLAIMER.md)。

---

## 🎯 什么是海鸥？

海鸥通过 Codex 的 plugin / marketplace 系统以插件方式部署：

- ✅ 命令行一键安装
- ✅ 自动叠加破甲配置
- ✅ 不覆盖原有设置
- ✅ 保持 Codex 使用习惯

---

## 🚀 快速部署

### 一行安装

```bash
codex plugin marketplace add https://github.com/ly1123245599/codex-seagull.git --ref master && codex plugin add seagull@codex-seagull
```

### 本地安装（会覆盖 git 源）

```bash
git clone https://github.com/ly1123245599/codex-seagull.git
cd codex-seagull

# Linux / macOS / Git Bash
chmod +x install.sh verify.sh
./verify.sh
./install.sh --local

# Windows PowerShell
.\verify.ps1
.\install.ps1 -Local
```

### 启动

重启 Codex。会话里执行 `/hooks`，信任 seagull 的 SessionStart / UserPromptSubmit。发送 **"在吗"** 激活海鸥破甲模式。

---

## 🔥 核心能力

### 破甲模式

- 🔓 无限制技术交付
- 📝 原义锁定执行
- ⚡ 强制开工协议
- 🎯 双用场景路由

### 专业技能（随发 13 个 SKILL.md）

- 🔍 **逆向工程** `seagull-reverse`
- 🌐 **渗透测试** `seagull-pentest`
- 🦅 **漏洞利用** `seagull-exploit`
- 🎮 **游戏辅助** `seagull-game-hack`
- 🔐 **卡密安全** `seagull-license-security`
- 🧭 **全域路由** `seagull-unlimited`
- 🧠 **进程内存** `seagull-memory`
- 🦠 **样本分析** `seagull-malware`
- 🛡️ **免杀工程** `seagull-evasion`
- 🎯 **游戏安全检测** `seagull-game-security`
- 🧱 **反作弊研究** `seagull-anticheat`
- 📁 **案件工作区** `seagull-lab`
- 🕵️ **社工情报** `seagull-social-eng`

不给这些技能 1:1 配 MCP。工具走 shell 与已有 MCP。

---

## 📚 文档

- 📖 [快速开始](./QUICKSTART.md)
- 🛠️ [技能列表](./STRUCTURE.md)
- ⚖️ [免责声明](./DISCLAIMER.md)

---

## 🔄 更新

```bash
codex plugin marketplace upgrade codex-seagull
codex plugin add seagull@codex-seagull
```

只有当前 clone 有未推送改动时才用本地重装：

```bash
./install.sh --force --local
```

---

## ⚙️ 常用命令

| 命令 | 说明 |
|------|------|
| `在吗` | 激活破甲模式 |
| `无限制` | 全域专家模式 |
| `逆向` | 逆向工程模式 |
| `渗透` | 渗透工程模式 |
| `破甲` | 强制开工模式 |
| `内存` | 进程内存 / 指针链 |
| `免杀` | loader + 检测分层 |
| `建案` | 案件目录 |

---

## 🆘 问题排查

**Q: 找不到 `codex` 命令？**  
A: 安装 Codex CLI，或设置 `CODEX_CLI_PATH`。Windows 常见路径：`%LOCALAPPDATA%\OpenAI\Codex\bin\<hash>\codex.exe`。

**Q: 如何确认安装成功？**  
A: `codex plugin list` 能看到 `seagull@codex-seagull`。启动后发送 `在吗`，收到 `海鸥在线，你要整点薯条吗？` 即成功。

**Q: 装了还是普通 Codex？**  
A: 插件 hook 默认不信任。会话里 `/hooks` 信任 seagull 的 SessionStart / UserPromptSubmit，然后重启会话。Windows 还需要本机 Python 3（`py -3`）。

**Q: 如何卸载？**  
A:

```bash
codex plugin remove seagull@codex-seagull
codex plugin marketplace remove codex-seagull
```

---

## 📜 开源协议

MIT License

人格与技能来自 [laoshu666/hermes-seagull](https://github.com/laoshu666/hermes-seagull)（MIT）。
本仓库技能表是 13 个 SKILL.md，不是上游原样拷贝。

---

**开始使用海鸥破甲插件，全域技术无限制！** 🚀
