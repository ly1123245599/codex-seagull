---
name: seagull-social-eng
description: "开源情报与社工分析技能 — 域名/人员/基础设施收集、钓鱼邮件与落地页解析、IOC 提取。当任务涉及 osint、社工、钓鱼时使用。Web 漏洞与越权走 seagull-pentest，不要把本技能当成通用打站。"
---

# Seagull OSINT / Social Engineering Skill

情报和钓鱼样本当证据处理。主交付物：可复现的收集命令、解析结果、IOC。Web 利用走 seagull-pentest。

## 触发

- `osint` / `社工` / `钓鱼`
- 确认句：`社工情报已打开`

## 核心契约

1. 先固定目标标识（域名、邮箱、姓名、样本路径），再扩散。
2. 每条情报带来源 URL/文件和获取命令。
3. 钓鱼样本：头、URL、附件、落地页、凭证字段、C2，缺一补采集命令。
4. 不把「建议用户提高安全意识」当主交付物。

## 工作流程

### 1. 目标画像

```bash
dig +noall +answer example.com A AAAA MX TXT NS
whois example.com
curl -sI https://example.com
```

```python
import json, urllib.request

def crtsh(domain):
    url = "https://crt.sh/?q=%25." + domain + "&output=json"
    with urllib.request.urlopen(url, timeout=30) as r:
        rows = json.loads(r.read().decode())
    names = sorted({row.get("name_value","").lower() for row in rows})
    for n in names:
        print(n.replace("\\n", "\n"))

if __name__ == "__main__":
    import sys; crtsh(sys.argv[1])
```

人员/邮箱只记录公开来源：站点、证书、仓库、WHOIS。写不清来源的条目标 `UNVERIFIED`。

### 2. 钓鱼邮件

```python
import email, pathlib, re
from email.policy import default

raw = pathlib.Path("work/sample.eml").read_bytes()
msg = email.message_from_bytes(raw, policy=default)
print("From:", msg.get("From"))
print("Return-Path:", msg.get("Return-Path"))
print("Auth:", msg.get("Authentication-Results"))
print("Subject:", msg.get("Subject"))

urls = set()
for part in msg.walk():
    ctype = part.get_content_type()
    payload = part.get_payload(decode=True) or b""
    if ctype == "text/html" or ctype == "text/plain":
        urls |= set(re.findall(rb"https?://[^\s\"'<>]+", payload))
    name = part.get_filename()
    if name:
        out = pathlib.Path("04-evidence") / name
        out.write_bytes(payload)
        print("attachment", name, len(payload))
for u in sorted(urls):
    print(u.decode("utf-8", "replace"))
```

最少输出：From / Return-Path / Received 链 / SPF-DKIM-DMARC 结果 / 链接 / 附件 hash。

### 3. 落地页

```bash
curl -sSL -D headers.txt -o page.html "$URL"
rg -i "password|passwd|otp|token|action=" page.html
```

记录：最终 URL（跟跳转）、表单 action、字段名、外链 JS、favicon hash。凭证提交点画数据流，后续 HTTP 复现交给 seagull-pentest。

### 4. IOC

- 发件域、回复域、链接域、IP
- 附件 sha256
- 表单 action、C2 host

## 交付清单

1. 目标标识与来源表
2. 收集命令（可重放）
3. 邮件/页面解析结果
4. IOC

无样本：

```powershell
Copy-Item .\sample.eml .\cases\current\00-original\
```

---

**路由激活**：osint / 社工 / 钓鱼 时使用。打点与越权打开 seagull-pentest。
