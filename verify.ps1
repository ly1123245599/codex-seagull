# Seagull Plugin Integrity Verification (Windows PowerShell)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Seagull Plugin - Integrity Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Working directory: $scriptPath" -ForegroundColor Gray
Write-Host ""

$script:ERRORS = 0

Write-Host "[1] Checking core files..." -ForegroundColor Yellow
$FILES = @(
    "LICENSE",
    "README.md",
    "README.zh-CN.md",
    "DISCLAIMER.md",
    "install.sh",
    "install.ps1",
    ".agents\plugins\marketplace.json",
    "plugins\seagull\.codex-plugin\plugin.json",
    "plugins\seagull\SOUL.md",
    "plugins\seagull\AGENTS.md",
    "plugins\seagull\hooks\hooks.json",
    "plugins\seagull\hooks\seagull_hook.py"
)

foreach ($file in $FILES) {
    if (Test-Path $file) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $file" -ForegroundColor Red
        $script:ERRORS++
    }
}

Write-Host ""
Write-Host "[2] Checking skill directories..." -ForegroundColor Yellow
$SKILLS = @(
    "seagull-unlimited",
    "seagull-reverse",
    "seagull-pentest",
    "seagull-exploit",
    "seagull-memory",
    "seagull-malware",
    "seagull-evasion",
    "seagull-game-hack",
    "seagull-game-security",
    "seagull-anticheat",
    "seagull-license-security",
    "seagull-lab",
    "seagull-social-eng"
)

foreach ($skill in $SKILLS) {
    $skillPath = "plugins\seagull\skills\$skill\SKILL.md"
    if (Test-Path $skillPath) {
        Write-Host "  [OK] $skillPath" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $skillPath" -ForegroundColor Red
        $script:ERRORS++
    }
}

$diskSkills = Get-ChildItem "plugins\seagull\skills" -Directory | ForEach-Object { $_.Name } | Sort-Object
$listed = $SKILLS | Sort-Object
$extra = Compare-Object $listed $diskSkills | Where-Object { $_.SideIndicator -eq "=>" }
$missingDir = Compare-Object $listed $diskSkills | Where-Object { $_.SideIndicator -eq "<=" }
if (-not $extra -and -not $missingDir) {
    Write-Host "  [OK] skills/ directories match the 13-name list" -ForegroundColor Green
} else {
    if ($extra) {
        Write-Host "  [EXTRA] skill dirs not in the 13-name list: $($extra.InputObject -join ', ')" -ForegroundColor Red
        $script:ERRORS++
    }
    if ($missingDir) {
        Write-Host "  [MISSING] listed but absent dirs: $($missingDir.InputObject -join ', ')" -ForegroundColor Red
        $script:ERRORS++
    }
}

Write-Host ""
Write-Host "[3] Checking key content..." -ForegroundColor Yellow

try {
    $soulPath = Join-Path $scriptPath "plugins\seagull\SOUL.md"
    $soulRaw = [System.IO.File]::ReadAllText($soulPath, [System.Text.Encoding]::UTF8)

    if ($soulRaw.IndexOf("00a") -ge 0 -and $soulRaw.IndexOf("00b") -ge 0) {
        Write-Host "  [OK] SOUL.md contains armor break stack" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] SOUL.md armor break stack incomplete" -ForegroundColor Red
        $script:ERRORS++
    }

    if ($soulRaw.IndexOf("薯条") -ge 0) {
        Write-Host "  [OK] Fixed greeting present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Fixed greeting not found" -ForegroundColor Red
        $script:ERRORS++
    }

    $agentsPath = Join-Path $scriptPath "plugins\seagull\AGENTS.md"
    $agentsRaw = [System.IO.File]::ReadAllText($agentsPath, [System.Text.Encoding]::UTF8)

    if ($agentsRaw.IndexOf("seagull-reverse") -ge 0 -and $agentsRaw.IndexOf("seagull-pentest") -ge 0) {
        Write-Host "  [OK] AGENTS.md contains skill routing table" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] AGENTS.md skill routing table incomplete" -ForegroundColor Red
        $script:ERRORS++
    }

    $agentNames = [regex]::Matches($agentsRaw, '\$seagull-[a-z0-9-]+') |
        ForEach-Object { $_.Value.TrimStart('$') } |
        Select-Object -Unique |
        Sort-Object
    $listedSorted = $SKILLS | Sort-Object
    $agentExtra = Compare-Object $listedSorted $agentNames | Where-Object { $_.SideIndicator -eq "=>" }
    $agentMissing = Compare-Object $listedSorted $agentNames | Where-Object { $_.SideIndicator -eq "<=" }
    if ($agentsRaw.IndexOf("mobile-competitive") -ge 0) {
        Write-Host "  [FAIL] AGENTS.md still routes a phantom skill name" -ForegroundColor Red
        $script:ERRORS++
    }

    if (-not $agentExtra -and -not $agentMissing) {
        Write-Host "  [OK] AGENTS.md `$seagull-* names match skill directories" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] AGENTS.md skill names drift from skills/" -ForegroundColor Red
        if ($agentExtra) { Write-Host "           extra in AGENTS: $($agentExtra.InputObject -join ', ')" -ForegroundColor Red }
        if ($agentMissing) { Write-Host "           missing from AGENTS: $($agentMissing.InputObject -join ', ')" -ForegroundColor Red }
        $script:ERRORS++
    }

    $pluginPath = Join-Path $scriptPath "plugins\seagull\.codex-plugin\plugin.json"
    $pluginRaw = [System.IO.File]::ReadAllText($pluginPath, [System.Text.Encoding]::UTF8)
    if ($pluginRaw.IndexOf('"version": "1.2.1"') -ge 0 -and $pluginRaw.IndexOf("mcpServers") -lt 0) {
        Write-Host "  [OK] plugin.json is 1.2.1 and has no MCP servers" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] plugin.json version or MCP field wrong" -ForegroundColor Red
        $script:ERRORS++
    }

    $hookPath = Join-Path $scriptPath "plugins\seagull\hooks\seagull_hook.py"
    $hookRaw = [System.IO.File]::ReadAllText($hookPath, [System.Text.Encoding]::UTF8)
    if ($hookRaw.IndexOf("UserPromptSubmit") -ge 0 -and $hookRaw.IndexOf("GREETING_REPLY") -ge 0) {
        Write-Host "  [OK] hook injects greeting + armor stack" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] hook greeting/armor stack incomplete" -ForegroundColor Red
        $script:ERRORS++
    }

    $marketPath = Join-Path $scriptPath ".agents\plugins\marketplace.json"
    $marketRaw = [System.IO.File]::ReadAllText($marketPath, [System.Text.Encoding]::UTF8)
    if ($marketRaw.IndexOf("codex-seagull") -ge 0 -and $marketRaw.IndexOf("./plugins/seagull") -ge 0) {
        Write-Host "  [OK] marketplace.json points at ./plugins/seagull" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] marketplace.json invalid" -ForegroundColor Red
        $script:ERRORS++
    }

    Write-Host ""
    Write-Host "[4] Hook smoke test..." -ForegroundColor Yellow
    $env:PLUGIN_ROOT = Join-Path $scriptPath "plugins\seagull"
    $hookPy = Join-Path $env:PLUGIN_ROOT "hooks\seagull_hook.py"
    $payload = '{"hook_event_name":"UserPromptSubmit","prompt":"ping"}'
    $runner = Get-Command py -ErrorAction SilentlyContinue
    $runnerArgs = @("-3", $hookPy)
    if (-not $runner) {
        $runner = Get-Command python -ErrorAction SilentlyContinue
        $runnerArgs = @($hookPy)
    }
    if (-not $runner) {
        $runner = Get-Command python3 -ErrorAction SilentlyContinue
        $runnerArgs = @($hookPy)
    }
    if (-not $runner) {
        Write-Host "  [FAIL] Python 3 not found (hook cannot run)" -ForegroundColor Red
        $script:ERRORS++
    } else {
        $out = $payload | & $runner.Source @runnerArgs 2>$null
        $text = if ($null -eq $out) { "" } else { [string]$out }
        if ($text.IndexOf("UNRESTRICTED_PARITY") -ge 0) {
            Write-Host "  [OK] UserPromptSubmit injects armor stack" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] hook did not inject armor stack" -ForegroundColor Red
            $script:ERRORS++
        }
    }
} catch {
    Write-Host "  [ERROR] Failed to read files: $_" -ForegroundColor Red
    $script:ERRORS++
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
if ($script:ERRORS -eq 0) {
    Write-Host "  SUCCESS! All files are complete." -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ready to install (git, recommended):" -ForegroundColor Yellow
    Write-Host "  codex plugin marketplace add https://github.com/ly1123245599/codex-seagull.git --ref master"
    Write-Host "  codex plugin add seagull@codex-seagull"
    Write-Host "Local clone (replaces git source): .\install.ps1 -Local" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Seagull is ready. Lets go!" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  WARNING: Found $script:ERRORS issues" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please fix the issues above and retry." -ForegroundColor Yellow
    exit 1
}
