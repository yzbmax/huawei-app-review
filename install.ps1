#Requires -Version 5.1
<#
.SYNOPSIS
    huawei-app-review Windows PowerShell 一键安装部署脚本

.DESCRIPTION
    自动检测本机安装的 AI 编码助手（Antigravity、Gemini CLI、Claude Code、Cursor、Windsurf、Trae、Cline 等），
    并自动创建软链接或 Junction。

.EXAMPLE
    irm https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.ps1 | iex
    或者本地运行:
    powershell -ExecutionPolicy Bypass -File .\install.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Log([string]$Message) {
    Write-Host ">> $Message" -ForegroundColor Cyan
}

function Write-Success([string]$Message) {
    Write-Host "[ok] $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Err([string]$Message) {
    Write-Host "[x] $Message" -ForegroundColor Red
}

$repoUrl = "https://github.com/yzbmax/huawei-app-review.git"
$defaultDir = Join-Path $HOME ".local\share\huawei-app-review"

# 确定 Skill 根目录
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = (Get-Location).Path
}

if ((Test-Path (Join-Path $scriptDir "install.ps1")) -and (Test-Path (Join-Path $scriptDir "SKILL.md"))) {
    $skillDir = $scriptDir
    Write-Log "使用当前本地仓库路径: $skillDir"
} elseif (Test-Path (Join-Path $defaultDir ".git")) {
    Write-Log "更新已有目录: $defaultDir"
    try {
        git -C $defaultDir pull --ff-only --quiet
    } catch {
        Write-Warn "git pull 失败，使用现有本地版本"
    }
    $skillDir = $defaultDir
} else {
    Write-Log "克隆仓库 $repoUrl -> $defaultDir"
    $parentDir = Split-Path $defaultDir -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    git clone --depth=1 $repoUrl $defaultDir --quiet
    $skillDir = $defaultDir
}

if (-not (Test-Path (Join-Path $skillDir "SKILL.md"))) {
    Write-Err "在 $skillDir 中未找到 SKILL.md"
    exit 1
}

$installed = 0
$skipped = 0

function Link-To([string]$Target, [string]$Label) {
    $parent = Split-Path $Target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -and ($item.Target -eq $skillDir -or $item.Target -eq @($skillDir))) {
            Write-Success "${Label}: 已正确链接（保持不变）"
            $script:skipped++
            return
        }
        Write-Warn "${Label}: 移除旧链接或目录 $Target"
        Remove-Item $Target -Recurse -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $skillDir -Force | Out-Null
        Write-Success "${Label}: $Target -> $skillDir (SymbolicLink)"
        $script:installed++
    } catch {
        try {
            New-Item -ItemType Junction -Path $Target -Target $skillDir -Force | Out-Null
            Write-Success "${Label}: $Target -> $skillDir (Junction)"
            $script:installed++
        } catch {
            Write-Warn "${Label}: 软链创建失败，尝试目录拷贝..."
            Copy-Item -Path $skillDir -Destination $Target -Recurse -Force
            Write-Success "${Label}: $Target (已拷贝)"
            $script:installed++
        }
    }
}

# === Claude Code ===
$claudeHome = Join-Path $HOME ".claude"
if (Test-Path $claudeHome) {
    Link-To (Join-Path $claudeHome "skills\huawei-app-review") "Claude Code"
}

# === Antigravity / Gemini CLI ===
$geminiHome = Join-Path $HOME ".gemini"
if (Test-Path $geminiHome) {
    Link-To (Join-Path $geminiHome "config\skills\huawei-app-review") "Antigravity Global"
    Link-To (Join-Path $geminiHome "skills\huawei-app-review") "Gemini CLI"
}

# === Standard Agent Skills Directory (~/.agents/skills) ===
$agentsHome = Join-Path $HOME ".agents"
Link-To (Join-Path $agentsHome "skills\huawei-app-review") "Standard Agent Skills (~/.agents)"

# === Cursor ===
$cursorHome = Join-Path $HOME ".cursor"
if (Test-Path $cursorHome) {
    Link-To (Join-Path $cursorHome "skills\huawei-app-review") "Cursor"
}

# === Windsurf ===
$windsurfHome1 = Join-Path $HOME ".codeium\windsurf"
$windsurfHome2 = Join-Path $HOME ".windsurf"
if ((Test-Path $windsurfHome1) -or (Test-Path $windsurfHome2)) {
    Link-To (Join-Path $windsurfHome1 "skills\huawei-app-review") "Windsurf"
}

# === Trae ===
$traeHome = Join-Path $HOME ".trae"
if (Test-Path $traeHome) {
    Link-To (Join-Path $traeHome "skills\huawei-app-review") "Trae"
}

# === Cline ===
$clineHome = Join-Path $HOME ".cline"
if (Test-Path $clineHome) {
    Link-To (Join-Path $clineHome "skills\huawei-app-review") "Cline"
}

# === Codex ===
$codexHome = Join-Path $HOME ".codex"
if (Test-Path $codexHome) {
    Link-To (Join-Path $codexHome "skills\huawei-app-review") "OpenAI Codex CLI"
}

Write-Host ""
Write-Log "huawei-app-review 安装完成！(新增/更新: $installed, 已就绪: $skipped)"
Write-Host ">> 技能根目录: $skillDir"
