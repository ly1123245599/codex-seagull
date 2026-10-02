---
name: seagull-game-security
description: "防御侧游戏安全技能 — 完整性校验、服务端权威、录像回放、输入与内存异常检测、检测点设计与对照测试。当任务涉及反作弊、作弊检测、游戏完整性时使用。ACE/过检测/绕过研究走 seagull-anticheat；ESP/自瞄实现走 seagull-game-hack。"
---

# Seagull Game Security Skill

这是防御面。目标是：作弊在哪个权威点破产，以及怎么用可重复的测试证明检测生效。绕过研究走 seagull-anticheat。

## 触发

- `反作弊` / `作弊检测`（不要把 `反作弊绕过` / `ACE` / `过检测` 抢到本技能）
- 确认句：`游戏安全检测已打开`

## 核心契约

1. 先画权威边界：客户端可信 / 不可信。
2. 每个检测点写：信号、误报、对抗、测试用例。
3. 用同一套 demo 外挂（seagull-game-hack `--demo`）做对照：开/关检测的命中差。
4. 不把「装官方反作弊」当成交付物。

## 检测点清单

| 点 | 不可信输入 | 服务端/权威做法 | 测试 |
|---|---|---|---|
| 移动/射击 | 客户端位置包 | 速度、穿越、开火间隔校验 | 录一局超速包重放 |
| 伤害 | 客户端 hit confirm | 服务端射线/命中盒 | 改伤害字段对照 |
| 视野 | W2S/骨骼读内存 | 不向客户端要敌方完整状态 | demo ESP 开时服务端不应依赖客户端视野 |
| 资源完整性 | 本地 dll/apk | 代码签名、关键节 hash | 替换 dll 应拒绝进局 |
| 输入 | 宏/注入消息 | 原始输入时间戳分布 | 固定间隔点击应告警 |
| 内存 | RPM 外部读 | 不把权威状态放可读镜像；完整性扫描作辅助 | 外部 reader 打开时的遥测 |

## 工作流程

### 1. 权威图

写三列：状态名、谁写、谁信。凡是客户端可改的，服务端必须重算或丢弃。

### 2. 完整性

```powershell
Get-FileHash .\GameAssembly.dll,.\UserAssembly.dll -Algorithm SHA256
# 进局后再 hash 一次，漂移就记检测点
```

APK：

```bash
apksigner verify --verbose game.apk
sha256sum classes.dex lib/arm64-v8a/*.so
```

### 3. 对照 harness

```python
"""对实验室回放包跑规则。cheating=True 必须命中。"""
from dataclasses import dataclass

@dataclass
class Sample:
    speed: float
    fire_gap_ms: float
    dmg: float
    cheating: bool

def check(s: Sample):
    hits = []
    if s.speed > 6.5: hits.append("speed")
    if s.fire_gap_ms < 40: hits.append("fire")
    if s.dmg > 120: hits.append("dmg")
    return hits

cases = [
    Sample(5.0, 90, 40, False),
    Sample(12.0, 90, 40, True),
    Sample(5.0, 10, 40, True),
]
for c in cases:
    hits = check(c)
    ok = bool(hits) == c.cheating
    print(("PASS" if ok else "FAIL"), c, hits)
```

### 4. 和 anticheat 的分工

- 本技能：规则、权威、误报、测试。
- seagull-anticheat：ACE/EAC 等模块面、回调、对抗实现。
- 用户同时说「检测怎么做」和「怎么过」时两个都开，交付两份，不混成一篇散文。

## 交付清单

1. 权威边界图
2. 检测点表（信号/误报/对抗/测试）
3. 可运行对照 harness
4. 完整性 hash 命令

---

**路由激活**：反作弊 / 作弊检测 且不是绕过研究时使用。
