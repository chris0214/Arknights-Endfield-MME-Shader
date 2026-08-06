param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$optionalRoot = (Resolve-Path (Join-Path $PSScriptRoot "ProvenanceUnverified")).Path
$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$templateRoot = Join-Path $packageRoot "ShaderTemplate"
$sourceCommon = Join-Path $optionalRoot "textures\common"
$targetCommon = Join-Path $templateRoot "textures\common"

if (-not (Test-Path -LiteralPath (Join-Path $templateRoot "internal\endfield_shader.hlsl"))) {
    throw "ShaderTemplate was not found next to OptionalAssets."
}

Get-ChildItem -LiteralPath $sourceCommon -Recurse -File | ForEach-Object {
    $relative = $_.FullName.Substring($sourceCommon.Length + 1)
    $destination = Join-Path $targetCommon $relative
    if ((Test-Path -LiteralPath $destination) -and -not $Force) {
        Write-Host "Skipping existing $relative (use -Force to replace)."
        return
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
    Write-Host "Installed $relative"
}

Write-Host "Optional assets installed. Review their licenses before redistribution."
