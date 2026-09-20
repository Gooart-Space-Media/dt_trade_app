Add-Type -AssemblyName System.Drawing

# Load JPEG (misnamed as .png)
$img = [System.Drawing.Image]::FromFile((Resolve-Path 'assets/logo.png').Path)

# Save as proper PNG first
$pngPath = Join-Path (Get-Location) 'assets/logo_real.png'
$img.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()
Write-Host "Converted JPEG to real PNG"

# Reload proper PNG
$img = [System.Drawing.Image]::FromFile($pngPath)

# Create ICO with multiple sizes
$sizes = @(16, 32, 48, 64, 128, 256)
$icoPath = Join-Path (Get-Location) 'windows\runner\resources\app_icon.ico'

$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter($ms)

# ICO Header
$bw.Write([Int16]0)
$bw.Write([Int16]1)
$bw.Write([Int16]$sizes.Count)

$imageDataList = New-Object System.Collections.ArrayList
$offset = 6 + ($sizes.Count * 16)

foreach ($size in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap($img, $size, $size)
    $pngStream = New-Object System.IO.MemoryStream
    $bmp.Save($pngStream, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngBytes = $pngStream.ToArray()
    $pngStream.Dispose()
    $bmp.Dispose()

    $w = if ($size -ge 256) { 0 } else { $size }
    $h = if ($size -ge 256) { 0 } else { $size }
    $bw.Write([Byte]$w)
    $bw.Write([Byte]$h)
    $bw.Write([Byte]0)
    $bw.Write([Byte]0)
    $bw.Write([Int16]1)
    $bw.Write([Int16]32)
    $bw.Write([Int32]$pngBytes.Length)
    $bw.Write([Int32]$offset)

    [void]$imageDataList.Add($pngBytes)
    $offset += $pngBytes.Length
}

foreach ($pngBytes in $imageDataList) {
    $bw.Write($pngBytes)
}

$bw.Flush()
[System.IO.File]::WriteAllBytes($icoPath, $ms.ToArray())
$bw.Dispose()
$ms.Dispose()
$img.Dispose()

Write-Host "ICO created at: $icoPath"
