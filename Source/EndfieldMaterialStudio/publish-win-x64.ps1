param(
    [string]$RuntimeRoot = "",
    [string]$OutputDirectory = "",
    [switch]$SelfContained
)

$ErrorActionPreference = "Stop"
$toolRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $toolRoot "..\.."))
$runtime = if ($RuntimeRoot) { [IO.Path]::GetFullPath($RuntimeRoot) } else { Join-Path $repoRoot "EndfieldMME" }
$publish = if ($OutputDirectory) { [IO.Path]::GetFullPath($OutputDirectory) } else { Join-Path $toolRoot "artifacts\release-win-x64" }
$runtime = $runtime.TrimEnd('\', '/')
$publish = $publish.TrimEnd('\', '/')
if (!(Test-Path -LiteralPath $runtime -PathType Container)) { throw "Missing runtime: $runtime" }
if (Test-Path -LiteralPath $publish) { throw "Output already exists; choose a new -OutputDirectory: $publish" }
if ($publish.StartsWith($runtime + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Output must not be inside the runtime.' }
$defaultArtifacts = Join-Path $toolRoot 'artifacts'
if ($publish.StartsWith($repoRoot + '\', [StringComparison]::OrdinalIgnoreCase) -and
    !$publish.StartsWith($defaultArtifacts + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Within the repository, publish only under Source/EndfieldMaterialStudio/artifacts.'
}

$notices = @('README.md', 'USER_GUIDE_CN.md', 'LICENSE', 'AUTHORS.md', 'REFERENCES.md',
    'THIRD_PARTY_NOTICES.md', 'ASSET_LICENSE_BOUNDARY_CN.md', 'ASSET_MANIFEST.json', 'CHANGELOG.md')
foreach ($name in $notices) {
    if (!(Test-Path -LiteralPath (Join-Path $repoRoot $name) -PathType Leaf)) { throw "Missing distribution document: $name" }
}
$tests = Join-Path $toolRoot 'EndfieldMaterialStudio.Tests'
$app = Join-Path $toolRoot 'EndfieldMaterialStudio.App\EndfieldMaterialStudio.App.csproj'
$config = Join-Path $toolRoot 'NuGet.Publish.Config'
$savedRuntime = $env:ENDFIELD_MME_RUNTIME
$savedPmx = $env:ENDFIELD_TEST_PMX
try {
    $env:ENDFIELD_MME_RUNTIME = $runtime
    $env:ENDFIELD_TEST_PMX = $null
    dotnet run --project $tests -c Release
    if ($LASTEXITCODE -ne 0) { throw "Runtime regression checks failed: $LASTEXITCODE" }
    $selfContainedValue = if ($SelfContained) { 'true' } else { 'false' }
    dotnet restore $app -r win-x64 --configfile $config -p:PublishSingleFile=true "-p:SelfContained=$selfContainedValue"
    if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed: $LASTEXITCODE" }
    $gui = Join-Path $publish 'GUI'
    dotnet publish $app -c Release -r win-x64 --self-contained $selfContainedValue --no-restore `
        -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true `
        -p:DebugType=None -p:DebugSymbols=false -o $gui
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed: $LASTEXITCODE" }

    $destination = Join-Path $publish 'EndfieldMME'
    New-Item -ItemType Directory -Path $destination | Out-Null
    # Copy only runtime categories; no development sources, build output or character packs.
    foreach ($file in Get-ChildItem -LiteralPath $runtime -File) {
        if ($file.Extension -in '.fx', '.fxsub', '.fxh', '.x' -or $file.Name -eq 'JitteredSamp.png') {
            Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $destination $file.Name)
        }
    }
    $categories = @{
        'internal' = @('.hlsl', '.inc', '.fxsub', '.fxh', '.cp932')
        'textures\common' = @('.png', '.dds')
        'textures\environment_presets' = @('.dds', '.json')
        'docs\reference' = @('.txt')
    }
    foreach ($relative in $categories.Keys) {
        $sourceDirectory = Join-Path $runtime $relative
        if (!(Test-Path -LiteralPath $sourceDirectory -PathType Container)) { throw "Missing runtime directory: $relative" }
        foreach ($file in Get-ChildItem -LiteralPath $sourceDirectory -Recurse -File) {
            if ($file.Extension -notin $categories[$relative]) { throw "Unexpected runtime file: $($file.FullName)" }
            $target = Join-Path $destination $file.FullName.Substring($runtime.Length + 1)
            New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $target
        }
    }
    $controllers = @('Endfield_controller.pmx', 'EndfieldCloth_controller.pmx', 'EndfieldFace_controller.pmx',
        'EndfieldHair_controller_Range5.pmx', 'EndfieldSkin_controller.pmx', 'EndfieldPost_controller.pmx')
    New-Item -ItemType Directory -Path (Join-Path $destination 'controller') | Out-Null
    foreach ($name in $controllers) {
        Copy-Item -LiteralPath (Join-Path $runtime "controller\$name") -Destination (Join-Path $destination "controller\$name")
    }
    foreach ($name in $notices) { Copy-Item -LiteralPath (Join-Path $repoRoot $name) -Destination (Join-Path $publish $name) }
    Copy-Item -LiteralPath (Join-Path $repoRoot 'docs') -Destination (Join-Path $publish 'docs') -Recurse

    $env:ENDFIELD_MME_RUNTIME = $destination
    dotnet run --project $tests -c Release --no-build
    if ($LASTEXITCODE -ne 0) { throw "Packaged runtime checks failed: $LASTEXITCODE" }
    if (!(Test-Path -LiteralPath (Join-Path $gui 'EndfieldMaterialStudio.exe'))) { throw 'Missing GUI executable.' }
    $files = @(Get-ChildItem -LiteralPath $publish -Recurse -File)
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($publish.Length + 1).Replace('\', '/')
        if ($relative -match '(^|/)(bin|obj|Source|ShaderTemplate|\.git|\.nuget|\.codebase-memory|artifacts|backup)(/|$)' -or
            $file.Extension -in '.pdb', '.log', '.blend', '.pmm', '.emm', '.cs', '.zip') { throw "Unexpected release file: $relative" }
        if ($file.Extension -eq '.pmx' -and $relative -notlike 'EndfieldMME/controller/*') { throw "Character model in release: $relative" }
    }
    $hashLines = $files | Sort-Object FullName | ForEach-Object {
        '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $_.FullName.Substring($publish.Length + 1).Replace('\', '/')
    }
    [IO.File]::WriteAllLines((Join-Path $publish 'SHA256SUMS.txt'), [string[]]$hashLines, [Text.UTF8Encoding]::new($false))
    Write-Host "Published local candidate: $publish"
} finally {
    $env:ENDFIELD_MME_RUNTIME = $savedRuntime
    $env:ENDFIELD_TEST_PMX = $savedPmx
}