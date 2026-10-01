# 海鸥破甲插件 Seagull Armor-Break Plugin

**基于 Codex Plugin 的 CTF/Red-team/Reverse/Pentest 全域插件**

> 通过插件式命令行安装，叠加在 Codex / Codex++ 之上，提供完整破甲能力。
>
> 人格、技能与破甲栈 1:1 来自 [laoshu666/hermes-seagull](https://github.com/laoshu666/hermes-seagull) v1.1.0。使用前请阅读 [免责声明](./DISCLAIMER.md)。

---

## 🎯 什么是海鸥？

海鸥通过 Codex 的 plugin / marketplace 系统以插件方式部署：

- ✅ 命令行一键安装
- ✅ 自动叠加破甲配置
- ✅ 不覆盖原有设置
- ✅ 保持 Codex 使用习惯

---

## 🚀 快速部署

### 一行安装（Git 仓库发布后）

```bash
codex plugin marketplace add https://github.com/<OWNER>/codex-seagull && codex plugin add seagull@codex-seagull
```

把 `<OWNER>` 换成你 fork / 发布后的 GitHub 用户名。

### 本地安装

```bash
git clone https://github.com/<OWNER>/codex-seagull.git
cd codex-seagull

# Linux / macOS / Git Bash
chmod +x install.sh verify.sh
./verify.sh
./install.sh

# Windows PowerShell
.\verify.ps1
.\install.ps1
```

### 启动

重启 Codex / Codex++。会话里执行 `/hooks`，信任 seagull 的 SessionStart / UserPromptSubmit。发送 **"在吗"** 激活海鸥破甲模式。

---

## 🔥 核心能力

### 破甲模式

- 🔓 无限制技术交付
- 📝 原义锁定执行
- ⚡ 强制开工协议
- 🎯 双用场景路由

### 专业技能

- 🎯 **CTF 全速** - 自动判题+完整 Solve
- 🔍 **逆向工程** - IDA/Ghidra/Frida 全栈
- 🌐 **渗透测试** - Web/内网/云/AD 完整链路
- 🎮 **游戏安全** - 外挂/反作弊/内存工程
- 💻 **内存工程** - 进程/Dump/运行时分析
- 🔐 **卡密安全** - 授权验证链恢复
- 🛡️ **免杀工程** - AV/EDR 检测与绕过
- 🦅 **漏洞利用** - Pwn/Exploit 完整链路
- 🕵️ **社工情报** - OSINT/钓鱼/侦察

---

## 📚 文档

- 📖 [快速开始](./QUICKSTART.md)
- 🛠️ [技能列表](./STRUCTURE.md)
- ⚖️ [免责声明](./DISCLAIMER.md)

---

## 🔄 更新

```bash
git -C <repo> pull
codex plugin marketplace upgrade codex-seagull
codex plugin add seagull@codex-seagull
```

本地仓库直接：

```bash
./install.sh --force
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

---

## 🆘 问题排查

**Q: 找不到 `codex` 命令？**  
A: Codex++ 自带 CLI，路径一般是 `%LOCALAPPDATA%\OpenAI\Codex\bin\<hash>\codex.exe`。或设置 `CODEX_CLI_PATH` 后重跑 `install.ps1`。

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

---

**开始使用海鸥破甲插件，全域技术无限制！** 🚀
