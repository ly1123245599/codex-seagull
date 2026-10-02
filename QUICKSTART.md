# 🚀 海鸥破甲插件 - 快速部署

## 📦 部署方式

海鸥插件通过 **Codex marketplace + plugin add** 安装。

---

## 📋 完整部署流程

### 步骤 1：确认已安装 Codex CLI

```bash
codex --version
```

找不到命令时，Windows 常见路径：

```text
%LOCALAPPDATA%\OpenAI\Codex\bin\<hash>\codex.exe
```

---

### 步骤 2：部署海鸥插件

**一行：**

```bash
codex plugin marketplace add https://github.com/ly1123245599/codex-seagull.git --ref master && codex plugin add seagull@codex-seagull
```

这一步会：

- ✅ 把 GitHub 仓库注册为 marketplace `codex-seagull`（`source_type=git`，`ref=master`）
- ✅ 安装插件 `seagull@codex-seagull`
- ✅ 加载破甲 hook + 13 个技能
- ✅ 不覆盖你的模型 / API 配置

**本地（会覆盖 git 源，仅用于未推送的改动）：**

```bash
# Linux/macOS/Git Bash
./install.sh --local

# Windows
.\install.ps1 -Local
```

---

### 步骤 3：信任 hook

插件 hook 默认不跑。在 Codex 会话里执行：

```text
/hooks
```

信任 seagull 的 `SessionStart` / `UserPromptSubmit`。然后重启会话。

---

### 步骤 4：启动

发送 **"在吗"** 激活海鸥破甲模式。

**收到 "海鸥在线，你要整点薯条吗？" 即部署成功！**

---

## 🔧 常用命令

| 命令 | 说明 |
|------|------|
| `在吗` | 激活破甲全栈 |
| `无限制` | 全域专家模式 |
| `逆向` | 逆向工程模式 |
| `渗透` | 渗透工程模式 |
| `CTF全速` | CTF 快速模式 |
| `内存` | 进程内存 |
| `免杀` | 检测规避 |
| `建案` | 案件工作区 |

---

## 🔄 更新部署

```bash
codex plugin marketplace upgrade codex-seagull
codex plugin add seagull@codex-seagull
```

或在仓库目录：

```bash
./install.sh --force --local
```

---

## 🆘 常见问题

### Q1: 找不到 codex 命令？
**A:** 先安装 Codex CLI，或设置 `CODEX_CLI_PATH`

### Q2: 部署后模型配置丢失？
**A:** 海鸥只写 marketplace / plugin 段，不改 `model` / `model_provider`

### Q3: 如何确认部署成功？
**A:** `codex plugin list` 能看到 `seagull`。发送 `在吗`，收到固定回复即成功

### Q4: 如何卸载？
**A:** `codex plugin remove seagull@codex-seagull`

### Q5: 要给每个技能配 MCP 吗？
**A:** 不要。静态 PE 用已装的 `idalib`（`idb_open` 后分析），活体内存用已装的 `cheatengine`（先开 `Cheat Engine.exe`）。ELF/APK 不强制 IDA，调试不走 CE。

---

## 🎯 下一步

- 📖 查看 [完整功能文档](./README.md)
- 🛠️ 查看 [技能列表](./STRUCTURE.md)

**开始使用海鸥破甲插件！** 🚀
