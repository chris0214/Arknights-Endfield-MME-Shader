param(
    [string]$RuntimeRoot = "",
    [string]$OutputDirectory = "",
    [switch]$SelfContained
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Split-Path -Parent $root
$repoRoot = Split-Path -Parent $sourceRoot
$runtimeCandidates = @(
    $RuntimeRoot,
    $env:ENDFIELD_MME_RUNTIME,
    (Join-Path $repoRoot "EndfieldMME")
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
$runtime = $runtimeCandidates |
    ForEach-Object { [System.IO.Path]::GetFullPath($_) } |
    Where-Object { Test-Path -LiteralPath $_ -PathType Container } |
    Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($runtime)) {
    throw "Cannot find EndfieldMME. Pass -RuntimeRoot or set ENDFIELD_MME_RUNTIME."
}

$publish = if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    Join-Path $root "artifacts\release-win-x64"
} else {
    [System.IO.Path]::GetFullPath($OutputDirectory)
}
$stage = Join-Path $root "artifacts\publish-stage-win-x64"
$gui = Join-Path $publish "GUI"
$env:DOTNET_CLI_HOME = Join-Path $root ".dotnet_home"
$env:APPDATA = Join-Path $env:DOTNET_CLI_HOME "AppData"
$env:LOCALAPPDATA = Join-Path $env:DOTNET_CLI_HOME "LocalAppData"
$env:NUGET_PACKAGES = Join-Path $root ".nuget\packages"

foreach ($path in @($publish, $stage)) {
    if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
}

dotnet restore (Join-Path $root "EndfieldMaterialStudio.App\EndfieldMaterialStudio.App.csproj") `
    -r win-x64 --configfile (Join-Path $root "NuGet.Publish.Config") -p:NuGetAudit=false
if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed: $LASTEXITCODE" }
if ($SelfContained) {
    dotnet publish (Join-Path $root "EndfieldMaterialStudio.App\EndfieldMaterialStudio.App.csproj") `
        -c Release -r win-x64 --self-contained true --no-restore `
        -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true `
        -p:DebugType=None -p:DebugSymbols=false -o $stage
} else {
    dotnet publish (Join-Path $root "EndfieldMaterialStudio.App\EndfieldMaterialStudio.App.csproj") `
        -c Release -r win-x64 --self-contained false --no-restore `
        -p:PublishSingleFile=true -p:DebugType=None -p:DebugSymbols=false -o $stage
}
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed: $LASTEXITCODE" }

New-Item -ItemType Directory -Force -Path $gui | Out-Null
Copy-Item -LiteralPath (Join-Path $stage "EndfieldMaterialStudio.exe") -Destination (Join-Path $gui "EndfieldMaterialStudio.exe") -Force
Copy-Item -LiteralPath $runtime -Destination (Join-Path $publish "EndfieldMME") -Recurse -Force

foreach ($name in @(
    "README.md",
    "USER_GUIDE_CN.md",
    "AUTHORS.md",
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "ASSET_LICENSE_BOUNDARY_CN.md",
    "ASSET_MANIFEST.json",
    "REFERENCES.md",
    "RELEASE_NOTES_2.0.0_CN.md"
)) {
    $source = Join-Path $repoRoot $name
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination (Join-Path $publish $name) -Force
    }
}

Remove-Item -LiteralPath $stage -Recurse -Force
Write-Host "Published: $publish"
