param(
    [string]$RuntimeRoot = "",
    [string]$OutputDirectory = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $root
$runtimeCandidates = @(
    $RuntimeRoot,
    $env:ENDFIELD_MME_RUNTIME,
    (Join-Path $root "..\..\ShaderTemplate"),
    (Join-Path $root "..\EndfieldMME"),
    (Join-Path $root "ShaderTemplate")
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
$runtime = $runtimeCandidates |
    ForEach-Object { [System.IO.Path]::GetFullPath($_) } |
    Where-Object { Test-Path -LiteralPath $_ -PathType Container } |
    Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($runtime)) {
    throw "Cannot find the Endfield runtime. Pass -RuntimeRoot or set ENDFIELD_MME_RUNTIME."
}
$publish = if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    Join-Path $root "artifacts\publish-win-x64"
} else {
    [System.IO.Path]::GetFullPath($OutputDirectory)
}
$template = Join-Path $publish "ShaderTemplate"
$env:DOTNET_CLI_HOME = Join-Path $root ".dotnet_home"
$env:APPDATA = Join-Path $env:DOTNET_CLI_HOME "AppData"
$env:LOCALAPPDATA = Join-Path $env:DOTNET_CLI_HOME "LocalAppData"
$localPackages = Join-Path $root ".nuget"
$sharedPackages = Join-Path $workspace "EndfieldShaderTool\.nuget\packages"
$env:NUGET_PACKAGES = if (Test-Path -LiteralPath $sharedPackages -PathType Container) {
    $sharedPackages
} else {
    $localPackages
}

if (Test-Path -LiteralPath $publish) { Remove-Item -LiteralPath $publish -Recurse -Force }
dotnet restore (Join-Path $root "EndfieldMaterialStudio.slnx") -r win-x64 --ignore-failed-sources -p:NuGetAudit=false
if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed: $LASTEXITCODE" }
dotnet publish (Join-Path $root "EndfieldMaterialStudio.App\EndfieldMaterialStudio.App.csproj") `
    -c Release -r win-x64 --self-contained true --no-restore `
    -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:DebugType=None -p:DebugSymbols=false -o $publish
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed: $LASTEXITCODE" }

New-Item -ItemType Directory -Force -Path $template | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $template "docs\reference") | Out-Null
foreach ($notice in @("HgShadow_Readme.txt", "ray_mmd_LICENSE.txt")) {
    $noticeSource = Join-Path $runtime "docs\reference\$notice"
    if (Test-Path -LiteralPath $noticeSource) {
        Copy-Item -LiteralPath $noticeSource -Destination (Join-Path $template "docs\reference\$notice") -Force
    }
}
Copy-Item -LiteralPath (Join-Path $runtime "internal") -Destination (Join-Path $template "internal") -Recurse -Force
Copy-Item -LiteralPath (Join-Path $runtime "controller") -Destination (Join-Path $template "controller") -Recurse -Force
New-Item -ItemType Directory -Force -Path (Join-Path $template "textures") | Out-Null
Copy-Item -LiteralPath (Join-Path $runtime "textures\common") -Destination (Join-Path $template "textures\common") -Recurse -Force
$fixedTextures = @(
    "T_actor_common_body_01_RD.png",
    "T_actor_common_cloth_04_RD.png",
    "T_actor_common_cloth_04_RS.png",
    "T_actor_common_cloth_lut_01_D.png",
    "T_actor_common_face_01_RD.png",
    "T_actor_common_face_01_hl_M.png",
    "T_actor_common_female_face_01_cm_M.png",
    "T_actor_common_female_face_01_SDF.png",
    "T_actor_common_female_face_01_ST.png",
    "T_actor_common_femaleskincolor02_lut_D.png",
    "T_actor_common_hair_01_RD.png",
    "T_actor_common_hair_08_RS.png",
    "T_actor_common_hairline_03_M.png",
    "T_actor_common_hairst_01_ST.png",
    "T_actor_common_matcap_05_D.png",
    "T_actor_common_matcap_07_D.png"
)
foreach ($name in $fixedTextures) {
    $source = Join-Path $runtime "textures\common\$name"
    if (-not (Test-Path -LiteralPath $source)) { $source = Join-Path $runtime "textures\chen\$name" }
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing fixed runtime texture: $name" }
    Copy-Item -LiteralPath $source -Destination (Join-Path $template "textures\common\$name") -Force
}
if (Test-Path -LiteralPath (Join-Path $runtime "textures\environment_presets")) {
    Copy-Item -LiteralPath (Join-Path $runtime "textures\environment_presets") -Destination (Join-Path $template "textures\environment_presets") -Recurse -Force
}

$files = @(
    "EndfieldHair_Final.fx", "EndfieldFace_Final.fx",
    "EndfieldFace_ChenQianyu.fx", "EndfieldHair_ChenQianyu.fx",
    "EndfieldCloth_ChenQianyu.fx", "EndfieldSkin_ChenQianyu.fx",
    "EndfieldEyeBase_ChenQianyu.fx", "EndfieldEyeHighlight_ChenQianyu.fx",
    "EndfieldEyeWhite_ChenQianyu.fx", "EndfieldFacial_ChenQianyu.fx",
    "EndfieldMouth_ChenQianyu.fx", "EndfieldEyeOverlay_ChenQianyu.fx",
    "EndfieldBrowOverlay_ChenQianyu.fx", "EndfieldEyeThrough_Capture_ChenQianyu.fxsub",
    "EndfieldEyeThrough_Mask.fxsub", "EndfieldHairVisibility_Capture.fxsub",
    "EndfieldEyeThrough.fx", "EndfieldEyeThrough.x",
    "ZMDshadow.x", "ZMDshadow.fx", "ZMDshadow_ShadowMap.fxsub", "ZMDshadow_ViewportMap.fxsub",
    "HgShadow_CFSUSM.fxh", "HgShadow_CLSPSM.fxh", "HgShadow_Header.fxh",
    "EndfieldPost.fx", "EndfieldPost.x", "JitteredSamp.png"
)
foreach ($name in $files) {
    $source = Join-Path $runtime $name
    if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination (Join-Path $template $name) -Force }
}

Copy-Item -LiteralPath (Join-Path $root "README.md") -Destination (Join-Path $publish "README.md") -Force
foreach ($name in @(
    "USER_GUIDE_CN.md",
    "AUTHORS.md",
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "ASSET_LICENSE_BOUNDARY_CN.md",
    "ASSET_MANIFEST_2.0.0.json",
    "REFERENCES.md",
    "RELEASE_NOTES_2.0.0_CN.md"
)) {
    $source = Join-Path $root $name
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination (Join-Path $publish $name) -Force
    }
}
Write-Host "Published: $publish"

