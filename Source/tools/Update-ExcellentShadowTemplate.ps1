param(
    [Parameter(Mandatory = $true)]
    [string]$TemplateRoot
)

$ErrorActionPreference = "Stop"
$encoding = [System.Text.Encoding]::GetEncoding(932)

function Read-Cp932([string]$Path) {
    return $encoding.GetString([System.IO.File]::ReadAllBytes($Path))
}

$checks = @(
    @{
        File = "ExcellentShadowCommonSystem.fx"
        Required = @(
            'static float4x4 LightViewMatrix = VecToMatrix(float3(0,0,1), normalize(LightDirVec));',
            'static float4x4 InternalLightWorldViewProjMatrix = mul(BaseWorldMatrix, mul(mul(LightWorldMatrix, LightViewMatrix), LightProjMatrix));'
        )
    },
    @{
        File = "ExcellentShadowObject.fxsub"
        Required = @('Out.IZCalcTex = mul( pos, InternalLightWorldViewProjMatrix );')
    },
    @{
        File = "ExcellentShadowZBufDraw.fxsub"
        Required = @(
            'Out.Pos = mul( pos, InternalLightWorldViewProjMatrix );',
            'compile vs_2_0 Basic_VS(',
            'compile ps_2_0 Basic_PS('
        )
    },
    @{
        File = "ExcellentShadowZBufDrawFar.fxsub"
        Required = @(
            'Out.Pos = mul( pos, InternalLightWorldViewProjMatrix );',
            'compile vs_2_0 Basic_VS(',
            'compile ps_2_0 Basic_PS('
        )
    }
)

foreach ($check in $checks) {
    $path = Join-Path $TemplateRoot $check.File
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required ExcellentShadow file is missing: $path"
    }

    $source = Read-Cp932 $path
    foreach ($requiredText in $check.Required) {
        if (-not $source.Contains($requiredText)) {
            throw "Known-working ExcellentShadow baseline check failed in $($check.File): $requiredText"
        }
    }
    if ($source.Contains('ES_TransformInternalShadowPosition')) {
        throw "Unsupported custom shadow transform found in $($check.File). Restore the known-working baseline."
    }
}

Write-Host "ExcellentShadow known-working baseline verified (no files modified): $TemplateRoot"


