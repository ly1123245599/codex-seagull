---
name: seagull-lab
description: "案件工作区技能 — 固定目录、原始样本只读拷贝、hash、triage 笔记、证据打包与 writeup。当任务涉及建案、case、工作空间，或 CTF 全速需要可复现目录时使用。具体解题仍路由到对应专业技能。"
---

# Seagull Lab Case Skill

先建案再动手。原始字节只进 `00-original/`，工作拷贝进 `03-work/`。本技能不代替 reverse/pentest/exploit。

## 触发

- `建案` / `case` / `工作空间`
- `CTF全速模式` / `比赛模式` / `题目模式` 时作为第一步隐式激活
- 确认句：`案件工作区已打开`

## 目录契约

```text
cases/<YYYYMMDD>-<slug>/
  00-original/     只读原件，禁止改
  01-hash.txt      sha256 + 文件名 + 字节数
  02-triage.md     格式/架构/保护/题型
  03-work/         可变工作拷贝
  04-evidence/     截图、pcap、dump、请求包
  05-notes.md      命令与假设
  06-writeup.md    最短复现路径
  07-result.txt    flag/结论
```

slug：小写、短横线、不超过 40 字符，从题目或样本名来。

## 建案脚本

```python
#!/usr/bin/env python3
import argparse, datetime, hashlib, pathlib, shutil, sys

ROOT = pathlib.Path("cases")

def sha256(p: pathlib.Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("slug")
    ap.add_argument("artifacts", nargs="*")
    args = ap.parse_args()
    day = datetime.date.today().strftime("%Y%m%d")
    case = ROOT / f"{day}-{args.slug}"
    for name in ("00-original", "03-work", "04-evidence"):
        (case / name).mkdir(parents=True, exist_ok=True)
    lines = []
    for src in args.artifacts:
        p = pathlib.Path(src)
        dst = case / "00-original" / p.name
        if dst.exists():
            raise SystemExit(f"refusing to overwrite {dst}")
        shutil.copy2(p, dst)
        shutil.copy2(p, case / "03-work" / p.name)
        digest = sha256(dst)
        lines.append(f"{digest}  {p.name}  {dst.stat().st_size}")
        print(f"{digest}  {p.name}")
    (case / "01-hash.txt").write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    for rel, body in {
        "02-triage.md": "# Triage\n\n- format:\n- arch:\n- protection:\n- category:\n",
        "05-notes.md": "# Notes\n",
        "06-writeup.md": "# Writeup\n",
        "07-result.txt": "",
    }.items():
        path = case / rel
        if not path.exists():
            path.write_text(body, encoding="utf-8")
    print(case)

if __name__ == "__main__":
    sys.exit(main())
```

```powershell
python tools\new_case.py pwn-baby .\baby.elf
```

## 工作规则

1. 分析、patch、跑 exploit 只用 `03-work/`。
2. 新证据丢 `04-evidence/`，文件名带步骤序号。
3. 命令原样记进 `05-notes.md`。
4. flag 只写 `07-result.txt`，writeup 写最短复现，不写情绪。
5. 打包：

```powershell
Compress-Archive -Path .\cases\20261002-pwn-baby\* -DestinationPath .\cases\20261002-pwn-baby.zip
Get-FileHash .\cases\20261002-pwn-baby.zip -Algorithm SHA256
```

## 与 CTF 全速的衔接

1. 本技能建目录、hash、拷贝
2. `02-triage.md` 填完立刻路由到 reverse / exploit / pentest / ...
3. 产物回写 `03-work` 与 `07-result.txt`

## 交付清单

1. 案件路径
2. `01-hash.txt`
3. 已拷贝的 work 文件
4. 下一步要打开的专业技能名

---

**路由激活**：建案 / case / 工作空间 / CTF 全速第一步时使用。
