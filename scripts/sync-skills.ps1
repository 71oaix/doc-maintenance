# 将仓库 skills/ 同步到 ~/.pi/agent/skills/（部署副本）
# 用法：powershell -ExecutionPolicy Bypass -File scripts/sync-skills.ps1
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'skills'
$target = Join-Path $HOME '.pi\agent\skills'
$targetFull = [IO.Path]::GetFullPath($target)

if (-not (Test-Path $source)) { throw "找不到技能源码目录：$source" }
if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }

Get-ChildItem $source -Directory | ForEach-Object {
    $dest = [IO.Path]::GetFullPath((Join-Path $target $_.Name))
    if (-not $dest.StartsWith($targetFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw "目标路径越界，已中止：$dest"
    }
    if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
    Write-Host "已同步：$($_.Name)"
}

Write-Host "同步完成 → $targetFull"
