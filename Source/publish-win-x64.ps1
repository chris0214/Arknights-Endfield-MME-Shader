param()

$ErrorActionPreference = "Stop"
$toolRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $toolRoot
$env:DOTNET_CLI_HOME = Join-Path $toolRoot ".dotnet_home"
$env:APPDATA = Join-Path $env:DOTNET_CLI_HOME "AppData"
$env:LOCALAPPDATA = Join-Path $env:DOTNET_CLI_HOME "LocalAppData"
$env:NUGET_PACKAGES = Join-Path $toolRoot ".nuget"
$project = Join-Path $toolRoot "EndfieldShaderTool.App\EndfieldShaderTool.App.csproj"
$config = Join-Path $toolRoot "NuGet.Publish.Config"
$publish = Join-Path $toolRoot "artifacts\publish"

New-Item -ItemType Directory -Force -Path $env:DOTNET_CLI_HOME, $env:APPDATA, $env:LOCALAPPDATA, $env:NUGET_PACKAGES | Out-Null
if (Test-Path -LiteralPath $publish) { Remove-Item -LiteralPath $publish -Recurse -Force }

dotnet publish $project `
    --configuration Release `
    --no-restore `
    -p:RuntimeIdentifier= `
    -p:SelfContained=false `
    -p:PublishSingleFile=false `
    -p:DebugType=None `
    -p:DebugSymbols=false `
    --output $publish
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed with exit code $LASTEXITCODE" }

Copy-Item -LiteralPath (Join-Path $toolRoot "README.md") -Destination (Join-Path $publish "README.md") -Force
Copy-Item -LiteralPath (Join-Path $toolRoot "AUTHORS.md") -Destination (Join-Path $publish "AUTHORS.md") -Force
Write-Host "Published: $publish"



