param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Convert-SrgbToLinear([byte]$Value) {
    $x = [double]$Value / 255.0
    if ($x -le 0.04045) {
        return $x / 12.92
    }
    return [Math]::Pow(($x + 0.055) / 1.055, 2.4)
}

function Convert-LinearToSrgb([double]$Value) {
    $x = [Math]::Max(0.0, [Math]::Min(1.0, $Value))
    if ($x -le 0.0031308) {
        $srgb = $x * 12.92
    }
    else {
        $srgb = 1.055 * [Math]::Pow($x, 1.0 / 2.4) - 0.055
    }
    return [byte][Math]::Round(
        [Math]::Max(0.0, [Math]::Min(1.0, $srgb)) * 255.0)
}

function New-LinearDownsample([System.Drawing.Bitmap]$Source) {
    $width = [Math]::Max([int]($Source.Width / 2), 1)
    $height = [Math]::Max([int]($Source.Height / 2), 1)
    $result = [System.Drawing.Bitmap]::new(
        $width,
        $height,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    for ($y = 0; $y -lt $height; ++$y) {
        for ($x = 0; $x -lt $width; ++$x) {
            $r = 0.0
            $g = 0.0
            $b = 0.0
            $a = 0.0
            $sampleCount = 0

            for ($oy = 0; $oy -lt 2; ++$oy) {
                for ($ox = 0; $ox -lt 2; ++$ox) {
                    $sx = [Math]::Min($x * 2 + $ox, $Source.Width - 1)
                    $sy = [Math]::Min($y * 2 + $oy, $Source.Height - 1)
                    $color = $Source.GetPixel($sx, $sy)
                    $r += Convert-SrgbToLinear $color.R
                    $g += Convert-SrgbToLinear $color.G
                    $b += Convert-SrgbToLinear $color.B
                    $a += [double]$color.A / 255.0
                    ++$sampleCount
                }
            }

            $result.SetPixel(
                $x,
                $y,
                [System.Drawing.Color]::FromArgb(
                    [byte][Math]::Round($a / $sampleCount * 255.0),
                    (Convert-LinearToSrgb ($r / $sampleCount)),
                    (Convert-LinearToSrgb ($g / $sampleCount)),
                    (Convert-LinearToSrgb ($b / $sampleCount))))
        }
    }

    return $result
}

function Copy-BitmapPixels(
    [System.Drawing.Bitmap]$Source,
    [System.Drawing.Bitmap]$Destination,
    [int]$DestinationX,
    [int]$DestinationY) {
    for ($y = 0; $y -lt $Source.Height; ++$y) {
        for ($x = 0; $x -lt $Source.Width; ++$x) {
            $Destination.SetPixel(
                $DestinationX + $x,
                $DestinationY + $y,
                $Source.GetPixel($x, $y))
        }
    }
}

$sourcePath = [System.IO.Path]::GetFullPath($InputPath)
$destinationPath = [System.IO.Path]::GetFullPath($OutputPath)

if (-not [System.IO.File]::Exists($sourcePath)) {
    throw "Input MatCap does not exist: $sourcePath"
}

$source = [System.Drawing.Bitmap]::new($sourcePath)
try {
    if ($source.Width -ne $source.Height) {
        throw 'MatCap must be square.'
    }
    if (($source.Width -band ($source.Width - 1)) -ne 0) {
        throw 'MatCap size must be a power of two.'
    }

    $atlas = [System.Drawing.Bitmap]::new(
        $source.Width + [int]($source.Width / 2),
        $source.Height,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        Copy-BitmapPixels $source $atlas 0 0

        $previous = [System.Drawing.Bitmap]::new($source)
        try {
            $mipY = 0
            while ($previous.Width -gt 1) {
                $next = New-LinearDownsample $previous
                $previous.Dispose()
                $previous = $next
                Copy-BitmapPixels $previous $atlas $source.Width $mipY
                $mipY += $previous.Height
            }
        }
        finally {
            $previous.Dispose()
        }

        $destinationDirectory = [System.IO.Path]::GetDirectoryName(
            $destinationPath)
        [System.IO.Directory]::CreateDirectory($destinationDirectory) | Out-Null
        $atlas.Save(
            $destinationPath,
            [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $atlas.Dispose()
    }
}
finally {
    $source.Dispose()
}

Write-Output "Generated MatCap mip atlas: $destinationPath"
