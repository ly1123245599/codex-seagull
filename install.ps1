# 海鸥破甲智能体安装脚本 (Windows)
# PowerShell 5.1+
# 将本仓库注册为 Codex marketplace，并安装 seagull@codex-seagull

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  海鸥破甲智能体 - 安装向导" -ForegroundColor Cyan
Write-Host "  Seagull Plugin for Codex / Codex++" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

function Find-Codex {
    if ($env:CODEX_CLI_PATH -and (Test-Path $env:CODEX_CLI_PATH)) {
        return $env:CODEX_CLI_PATH
    }
    $cmd = Get-Command codex -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) {
        return $cmd.Source
    }
    $binRoot = Join-Path $env:LOCALAPPDATA "OpenAI\Codex\bin"
    if (Test-Path $binRoot) {
        $hit = Get-ChildItem $binRoot -Recurse -Filter "codex.exe" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

$Codex = Find-Codex
if (-not $Codex) {
    Write-Host "[错误] 未找到 Codex CLI" -ForegroundColor Red
    Write-Host "Codex++ 一般在: %LOCALAPPDATA%\OpenAI\Codex\bin\<hash>\codex.exe" -ForegroundColor Yellow
    Write-Host "或先安装官方 CLI，再重跑本脚本。" -ForegroundColor Yellow
    exit 1
}

$CodexVersion = & $Codex --version 2>&1
Write-Host "[✓] Codex CLI 已安装" -ForegroundColor Green
Write-Host "    路径: $Codex" -ForegroundColor Gray
Write-Host "    版本: $CodexVersion" -ForegroundColor Gray
Write-Host ""

$MarketplaceJson = Join-Path $RepoRoot ".agents\plugins\marketplace.json"
$PluginJson = Join-Path $RepoRoot "plugins\seagull\.codex-plugin\plugin.json"
if (-not (Test-Path $MarketplaceJson) -or -not (Test-Path $PluginJson)) {
    Write-Host "[错误] 仓库不完整，缺少 marketplace.json 或 plugin.json" -ForegroundColor Red
    exit 1
}

if ($Force) {
    Write-Host "[*] -Force：尝试移除旧 marketplace / 插件" -ForegroundColor Cyan
    & $Codex plugin remove seagull@codex-seagull 2>$null | Out-Null
    & $Codex plugin marketplace remove codex-seagull 2>$null | Out-Null
}

Write-Host "[*] 注册 marketplace: $RepoRoot" -ForegroundColor Cyan
$addOut = & $Codex plugin marketplace add $RepoRoot --json 2>&1
$addExit = $LASTEXITCODE
if ($addExit -ne 0) {
    Write-Host $addOut
    Write-Host "[!] marketplace add 返回 $addExit，继续尝试安装插件" -ForegroundColor Yellow
} else {
    Write-Host "[✓] marketplace 已注册" -ForegroundColor Green
}

Write-Host "[*] 安装插件 seagull@codex-seagull" -ForegroundColor Cyan
$installOut = & $Codex plugin add seagull@codex-seagull --json 2>&1
$installExit = $LASTEXITCODE
Write-Host $installOut
if ($installExit -ne 0) {
    Write-Host "[错误] 插件安装失败" -ForegroundColor Red
    exit $installExit
}
Write-Host "[✓] 插件已安装" -ForegroundColor Green
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  安装完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  1. 重启 Codex / Codex++"
Write-Host "  2. 确认插件 seagull@codex-seagull 已启用"
Write-Host "  3. 会话里执行 /hooks，信任 seagull 的 SessionStart / UserPromptSubmit"
Write-Host "  4. 发送 '在吗' 激活"
Write-Host ""
Write-Host "技能触发词：" -ForegroundColor Yellow
Write-Host "  - 逆向 / reverse"
Write-Host "  - 渗透 / pentest"
Write-Host "  - 外挂 / esp / 自瞄"
Write-Host "  - 卡密 / 破解 / license"
Write-Host "  - pwn / exploit"
Write-Host ""
Write-Host "海鸥在线。把目标扔来，老子直接开干。" -ForegroundColor Cyan
Write-Host ""
