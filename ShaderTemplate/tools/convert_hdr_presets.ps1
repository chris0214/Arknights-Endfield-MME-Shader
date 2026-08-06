param(
    [string]$SourceRoot,
    [string]$CmftArchive,
    [switch]$Force,
    [switch]$KeepWorkDirectory
)

$ErrorActionPreference = "Stop"

$mmeRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourceRootPath = if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    $null
} else {
    [System.IO.Path]::GetFullPath($SourceRoot)
}
$archivePath = if ([string]::IsNullOrWhiteSpace($CmftArchive)) {
    $null
} else {
    [System.IO.Path]::GetFullPath($CmftArchive)
}
$toolCache = Join-Path $PSScriptRoot "_hdr_work\cmft_rgbt_x1024"
$presetRoot = Join-Path $mmeRoot "textures\environment_presets"
$runtimePath = Join-Path $mmeRoot "textures\common\cloth_environment_current.dds"
$workRoot = Join-Path $env:TEMP "endfield_hdr_cmft"

$presetIds = @(
    "brown_photostudio_02",
    "monochrome_studio_02",
    "ferndale_studio_01",
    "studio_small_09",
    "abandoned_hopper_terminal_04",
    "abandoned_tank_farm_03",
    "abandoned_tank_farm_04"
)

if ([string]::IsNullOrWhiteSpace($sourceRootPath)) {
    throw "Pass -SourceRoot with the directory containing the seven *_4k.hdr files."
}

if (-not (Test-Path -LiteralPath $sourceRootPath -PathType Container)) {
    throw "HDR source directory not found: $sourceRootPath"
}

if ([string]::IsNullOrWhiteSpace($archivePath)) {
    throw "Pass -CmftArchive with the path to cmft_rgbt_x1024.zip. The archive is an external build dependency and is intentionally not bundled."
}

if (-not (Test-Path -LiteralPath $archivePath -PathType Leaf)) {
    throw "cmft archive not found: $archivePath"
}

if (-not (Test-Path -LiteralPath $toolCache)) {
    $cacheParent = Split-Path -Parent $toolCache
    New-Item -ItemType Directory -Path $cacheParent -Force | Out-Null
    Expand-Archive -LiteralPath $archivePath -DestinationPath $cacheParent -Force
}

$cmftSource = Join-Path $toolCache "cmft_x64_fast_rgbt.exe"
if (-not (Test-Path -LiteralPath $cmftSource)) {
    throw "cmft executable not found: $cmftSource"
}

function Get-DdsMetadata([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 128 -or
        [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne "DDS ") {
        return $null
    }

    return [pscustomobject]@{
        Width = [BitConverter]::ToInt32($bytes, 16)
        Height = [BitConverter]::ToInt32($bytes, 12)
        MipCount = [BitConverter]::ToInt32($bytes, 28)
        Length = $bytes.Length
    }
}

function Test-RuntimeDds([string]$Path) {
    $metadata = Get-DdsMetadata $Path
    return $null -ne $metadata -and
        $metadata.Width -eq 1024 -and
        $metadata.Height -eq 512 -and
        $metadata.MipCount -eq 7
}

New-Item -ItemType Directory -Path $presetRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $runtimePath) -Force |
    Out-Null

$resolvedWorkRoot = [System.IO.Path]::GetFullPath($workRoot)
$expectedWorkRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $env:TEMP "endfield_hdr_cmft"))
if ($resolvedWorkRoot -ne $expectedWorkRoot) {
    throw "Unexpected work directory: $resolvedWorkRoot"
}

if (Test-Path -LiteralPath $resolvedWorkRoot) {
    Remove-Item -LiteralPath $resolvedWorkRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $resolvedWorkRoot -Force | Out-Null

$cmftWork = Join-Path $resolvedWorkRoot "cmft.exe"
$hdrWork = Join-Path $resolvedWorkRoot "input.hdr"
Copy-Item -LiteralPath $cmftSource -Destination $cmftWork -Force

try {
    foreach ($presetId in $presetIds) {
        $sourcePath = Join-Path $sourceRootPath "${presetId}_4k.hdr"
        $targetPath = Join-Path $presetRoot "${presetId}.dds"
        if (-not (Test-Path -LiteralPath $sourcePath)) {
            throw "HDR source not found: $sourcePath"
        }
        if (-not $Force -and (Test-RuntimeDds $targetPath)) {
            Write-Host "Skipping valid preset $presetId"
            continue
        }

        Get-ChildItem -LiteralPath $resolvedWorkRoot -Filter "*.dds" |
            Remove-Item -Force
        Copy-Item -LiteralPath $sourcePath -Destination $hdrWork -Force

        Write-Host "Converting $presetId (1024x512 runtime profile)..."
        $process = Start-Process `
            -FilePath $cmftWork `
            -ArgumentList @($hdrWork) `
            -WorkingDirectory $resolvedWorkRoot `
            -WindowStyle Hidden `
            -Wait `
            -PassThru
        if ($process.ExitCode -ne 0) {
            throw "cmft failed for $presetId with exit code $($process.ExitCode)"
        }

        $generatedSpecular = Join-Path $resolvedWorkRoot "skyspec_hdr.dds"
        if (-not (Test-Path -LiteralPath $generatedSpecular)) {
            throw "cmft did not create skyspec_hdr.dds for $presetId"
        }
        if (-not (Test-RuntimeDds $generatedSpecular)) {
            $metadata = Get-DdsMetadata $generatedSpecular
            throw "Unexpected DDS output for ${presetId}: $($metadata | Out-String)"
        }

        Copy-Item -LiteralPath $generatedSpecular -Destination $targetPath -Force
        Write-Host "  -> $targetPath"
    }

    $defaultPath = Join-Path $presetRoot "monochrome_studio_02.dds"
    Copy-Item -LiteralPath $defaultPath -Destination $runtimePath -Force
    Write-Host "Default runtime slot -> $runtimePath"
}
finally {
    if (-not $KeepWorkDirectory -and (Test-Path -LiteralPath $resolvedWorkRoot)) {
        Remove-Item -LiteralPath $resolvedWorkRoot -Recurse -Force
    }
}
