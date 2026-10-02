---
name: seagull-memory
description: "进程内存与运行时结构技能 — 句柄/pid、模块基址、RPM/WPM、指针链、特征扫描、region dump、ctypes 结构恢复。当任务涉及内存、dump、指针链、运行时结构时使用。游戏绘制走 seagull-game-hack；样本解包走 seagull-malware。"
---

# Seagull Memory Engineering Skill

把进程内存当数据源。本技能只负责：打开目标、模块基址、读写、指针链、扫描、dump、结构覆盖。绘制/自瞄交给 seagull-game-hack；PE 静态解包交给 seagull-malware / seagull-reverse。

## 触发

- `内存` / `memory` / `dump` / `指针链`
- 确认句：`内存工程已打开`
- 被 game-hack / pentest / anticheat 作为辅技能调用时隐式激活

## 核心契约

1. 先拿到 pid + 模块基址，再谈偏移。
2. 指针链必须可复现：`mod+off -> [+]off -> ...`，每级打印值。
3. dump 写文件并记 `base, size, sha256`。
4. 缺进程时用 `--demo` 假内存页把 walker/scan 跑通，同一套 API 再接活体。

默认平台：Windows x64。Linux 用 `/proc/<pid>/maps` + `process_vm_readv`。

## 工具绑定

Windows 活体优先会话内 `mcp__cheatengine__*`：`ping`（确认 pipe）→ `open_process` → `get_process_info` / `enum_modules` / `read_memory`。
不要让操作员在 CE GUI 里点 Attach。CE 未开、pipe 不通时，先起官方入口 `Cheat Engine.exe`，再 MCP。
本轮没有 cheatengine 工具时，才用下面的 ctypes `MemorySession`。禁止给本技能 1:1 再配一座 MCP。

## 工作流程

### 1. 定位进程与模块

```powershell
Get-Process | Where-Object { $_.ProcessName -match 'target' } |
  Select-Object Id, ProcessName, @{n='WS';e={$_.WorkingSet64}}
```

```bash
# Linux
ps -eo pid,comm,rss | rg target
cat /proc/$PID/maps
```

### 2. 读写原语（Windows）

```python
import ctypes, ctypes.wintypes as wt, struct, pathlib

kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
psapi = ctypes.WinDLL("psapi", use_last_error=True)

PROCESS_ALL = 0x1F0FFF
MEM_COMMIT = 0x1000
PAGE_GUARD = 0x100
PAGE_NOACCESS = 0x01

class MODULEENTRY32W(ctypes.Structure):
    _fields_ = [
        ("dwSize", wt.DWORD), ("th32ModuleID", wt.DWORD), ("th32ProcessID", wt.DWORD),
        ("GlcCntUsage", wt.DWORD), ("ProccntUsage", wt.DWORD),
        ("modBaseAddr", ctypes.c_void_p), ("modBaseSize", wt.DWORD),
        ("hModule", wt.HMODULE), ("szModule", wt.WCHAR * 256),
        ("szExePath", wt.WCHAR * 260),
    ]

class MEMORY_BASIC_INFORMATION(ctypes.Structure):
    _fields_ = [
        ("BaseAddress", ctypes.c_void_p), ("AllocationBase", ctypes.c_void_p),
        ("AllocationProtect", wt.DWORD), ("RegionSize", ctypes.c_size_t),
        ("State", wt.DWORD), ("Protect", wt.DWORD), ("Type", wt.DWORD),
    ]

class MemorySession:
    def __init__(self, pid):
        self.pid = pid
        self.h = kernel32.OpenProcess(PROCESS_ALL, False, pid)
        if not self.h:
            raise OSError(f"OpenProcess {pid} failed: {ctypes.get_last_error()}")

    def close(self):
        if self.h:
            kernel32.CloseHandle(self.h)
            self.h = None

    def read(self, addr, size):
        buf = (ctypes.c_ubyte * size)()
        n = ctypes.c_size_t()
        if not kernel32.ReadProcessMemory(self.h, ctypes.c_void_p(addr), buf, size, ctypes.byref(n)):
            raise OSError(f"RPM {addr:#x}: {ctypes.get_last_error()}")
        return bytes(buf[:n.value])

    def write(self, addr, data):
        buf = (ctypes.c_ubyte * len(data)).from_buffer_copy(data)
        n = ctypes.c_size_t()
        if not kernel32.WriteProcessMemory(self.h, ctypes.c_void_p(addr), buf, len(data), ctypes.byref(n)):
            raise OSError(f"WPM {addr:#x}: {ctypes.get_last_error()}")
        return n.value

    def u64(self, addr):
        return struct.unpack("<Q", self.read(addr, 8))[0]

    def module_base(self, name):
        snap = kernel32.CreateToolhelp32Snapshot(0x18, self.pid)  # TH32CS_SNAPMODULE|32
        me = MODULEENTRY32W(); me.dwSize = ctypes.sizeof(me)
        kernel32.Module32FirstW(snap, ctypes.byref(me))
        name = name.lower()
        while True:
            if me.szModule.lower() == name:
                kernel32.CloseHandle(snap)
                return int(me.modBaseAddr), int(me.modBaseSize)
            if not kernel32.Module32NextW(snap, ctypes.byref(me)):
                break
        kernel32.CloseHandle(snap)
        raise FileNotFoundError(name)

    def chain(self, base, offsets, final_deref=False):
        """mod+off0 -> [+]off1 -> ...  每级打印。"""
        if not offsets:
            raise ValueError("empty chain")
        addr = base
        trail = []
        last = len(offsets) - 1
        for i, off in enumerate(offsets):
            addr = addr + off
            if i < last or final_deref:
                val = self.u64(addr)
                trail.append((hex(addr), hex(val)))
                addr = val
                if addr == 0:
                    raise ValueError(f"null at hop {i}: {trail}")
            else:
                trail.append((hex(addr), None))
        return addr, trail

    def dump(self, addr, size, path):
        data = self.read(addr, size)
        pathlib.Path(path).write_bytes(data)
        return path, len(data)
```

指针链约定：`["GameAssembly.dll"+0x4A2B1C0, 0xB8, 0x20, 0x18]` 表示基址加第一个立即数，其后每一级先解引用再加。

### 3. 特征扫描

```python
def parse_pattern(pat: str):
    out, mask = bytearray(), []
    for tok in pat.split():
        if tok == "??":
            out.append(0); mask.append(False)
        else:
            out.append(int(tok, 16)); mask.append(True)
    return bytes(out), mask

def scan(sess, start, size, pat):
    needle, mask = parse_pattern(pat)
    blob = sess.read(start, size)
    hits = []
    for i in range(0, len(blob) - len(needle) + 1):
        if all((not m) or blob[i + j] == needle[j] for j, m in enumerate(mask)):
            hits.append(start + i)
    return hits
```

### 4. Linux

```python
import os, struct, ctypes, ctypes.util

libc = ctypes.CDLL(ctypes.util.find_library("c"), use_last_error=True)

class Iovec(ctypes.Structure):
    _fields_ = [("iov_base", ctypes.c_void_p), ("iov_len", ctypes.c_size_t)]

def vm_read(pid, addr, size):
    buf = ctypes.create_string_buffer(size)
    local = Iovec(ctypes.addressof(buf), size)
    remote = Iovec(addr, size)
    n = libc.process_vm_readv(pid, ctypes.byref(local), 1, ctypes.byref(remote), 1, 0)
    if n < 0:
        raise OSError("process_vm_readv")
    return buf.raw[:n]
```

### 5. Demo 假内存

没有活体进程时：在本地 `bytearray` 上实现同一套 `read/u64/chain/scan`，用已知链验证 walker，再把 `MemorySession` 换进去。禁止改 API。

## 交付清单

1. pid / 模块基址获取命令
2. 可运行 reader（含 chain + scan + dump）
3. 指针链逐步日志
4. dump 文件路径与 sha256
5. 结构体覆盖（ctypes / 注释偏移）

---

**路由激活**：用户提到内存、dump、指针链时使用本技能。游戏 overlay 仍走 seagull-game-hack。
