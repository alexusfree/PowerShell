<#
.SYNOPSIS
Resizes images, maintaining aspect ratio, and saves the output to a specified file or directory. The function can also simply re-save an image in a different format without resizing.

.DESCRIPTION
This function accepts one or more image file paths via a pipeline or direct parameter.
It scales the image to fit within the specified maximum width or height, while preserving the original aspect ratio. If only one of the maximum dimensions is specified, the other is calculated automatically. If only an output directory is provided, the function reuses the source file's name.

.PARAMETER InputPath
The path to the image file to be resized. Accepts both string paths and FileInfo objects from the pipeline.

.PARAMETER OutputPath
The path where the new image file will be saved. Can be a full file path or a directory path.

.PARAMETER Format
Optional. The format of the output file. Accepts 'jpg', 'jpeg', 'png', 'gif', 'bmp', and 'tiff'. Defaults to 'jpg'.

.PARAMETER MaxWidth
Optional. The maximum width in pixels for the resized image.

.PARAMETER MaxHeight
Optional. The maximum height in pixels for the resized image.

.PARAMETER SmoothingMode
Optional. Specifies the smoothing mode for rendering. Defaults to "HighQuality".

.PARAMETER InterpolationMode
Optional. Specifies the interpolation mode (scaling algorithm). Defaults to "HighQualityBicubic".

.PARAMETER PixelOffsetMode
Optional. Specifies the pixel offset mode. Defaults to "HighQuality".

.PARAMETER DisableRatio
Optional. A switch parameter. When present, the image's aspect ratio is not preserved. Used only in combination with -MaxWidth and -MaxHeight.

.PARAMETER DisableEXIF
Optional. A switch parameter. When present, metadata (EXIF) from the source file will not be transferred to the new file.

.EXAMPLE
# Resize a single file by width and save it as a PNG
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\small\photo_800.png" -MaxWidth 800 -Format png

.EXAMPLE
# Resize all JPG files in a folder to a maximum height of 600px and save them to another folder
Get-ChildItem -Path "C:\SourceImages" -Filter "*.jpg" | Resize-Image -OutputPath "C:\ResizedImages" -MaxHeight 600

.EXAMPLE
# Re-save a JPG file as a PNG without changing its dimensions
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\small\photo.png" -Format png

.EXAMPLE
# Resize an image to 1000x500, without preserving the aspect ratio
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\stretched.jpg" -MaxWidth 1000 -MaxHeight 500 -DisableRatio

.EXAMPLE
# Resize images located in subfolders
Get-ChildItem -Path "C:\SourceImages" -Recurse | Resize-Image -OutputPath "C:\ResizedImages" -MaxWidth 1280

.EXAMPLE
# Resize all .jpg, .png, .gif, .bmp, .tiff files to JPG with a new name
Get-ChildItem -Path "C:\SourceImages" | ForEach-Object { 
Resize-Image -InputPath $_ -OutputPath "$outputDir\Resize_$($_.BaseName)_800-600$($_.Extension)" -MaxWidth 800 -MaxHeight 600 }

.EXAMPLE
# Process all files in a directory without using the Get-ChildItem pipeline
Resize-Image -InputPath "C:\Images" -OutputPath "C:\ResizedImages" -MaxWidth 1280

.NOTES
The function requires .NET Framework with access to the System.Drawing assembly.
This function also transfers all metadata (EXIF) and creation/last write dates from the source file to the modified file. Metadata transfer can be disabled using the -DisableEXIF switch.
#>
function Resize-Image {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $InputPath,
        [Parameter(Mandatory=$true)] [string]$OutputPath,
        [Parameter(Mandatory=$false)]
        [ValidateSet('jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff')]
        [string]$Format = 'jpg',
        [Parameter(Mandatory=$false)] [int]$MaxWidth,
        [Parameter(Mandatory=$false)] [int]$MaxHeight,
        [Parameter(Mandatory=$False)]
        [System.Drawing.Drawing2D.SmoothingMode]$SmoothingMode = "HighQuality",
        [Parameter(Mandatory=$False)]
        [System.Drawing.Drawing2D.InterpolationMode]$InterpolationMode = "HighQualityBicubic",
        [Parameter(Mandatory=$False)]
        [System.Drawing.Drawing2D.PixelOffsetMode]$PixelOffsetMode = "HighQuality",
        [Parameter(Mandatory=$False)][Switch]$DisableRatio,
        [Parameter(Mandatory=$False)][Switch]$DisableEXIF
    )

    begin {
        try { Add-Type -AssemblyName System.Drawing } catch { Write-Error "Failed to load System.Drawing. Check your .NET Framework installation."; $script:canProcess = $false }
        $script:canProcess = $true
    }

    process {
        if (-not $script:canProcess) { return }
        if (Test-Path $InputPath -PathType Container) {
            Get-ChildItem -Path $InputPath -File | ForEach-Object { Resize-Image -InputPath $_.FullName @PSBoundParameters }
            return
        }

        if (-not (Test-Path $InputPath -PathType Leaf)) { Write-Warning "Input file '$InputPath' not found. Skipping."; return }
        $fileExtension = [System.IO.Path]::GetExtension($InputPath).TrimStart('.').ToLower()
        $supportedFormats = @('jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff')
        if (-not ($supportedFormats -contains $fileExtension)) { Write-Warning "Input file '$([System.IO.Path]::GetFileName($InputPath))' is not a supported format. Skipping."; return }

        $finalOutFile = if (Test-Path $OutputPath -PathType Container) { Join-Path $OutputPath -ChildPath (Split-Path $InputPath -Leaf) } else { $OutputPath }
        $outDir = Split-Path $finalOutFile -Parent
        $finalOutFile = Join-Path $outDir "$([System.IO.Path]::GetFileNameWithoutExtension($finalOutFile)).$Format"

        if (-not (Test-Path $outDir -PathType Container)) {
            try { New-Item -ItemType Directory -Path $outDir -Force | Out-Null } catch { Write-Error "Failed to create output directory '$outDir'."; return }
        }

        try {
            $creationTime = [System.IO.File]::GetCreationTime($InputPath)
            $lastWriteTime = [System.IO.File]::GetLastWriteTime($InputPath)
            $originalImage = [System.Drawing.Image]::FromFile($InputPath)
            
            if (-not $MaxWidth -and -not $MaxHeight) {
                $newWidth = $originalImage.Width
                $newHeight = $originalImage.Height
            } else {
                if ($DisableRatio) {
                    $newWidth = $MaxWidth
                    $newHeight = $MaxHeight
                } else {
                    $ratio = if (-not $MaxWidth) {
                        [double]$MaxHeight / $originalImage.Height
                    } elseif (-not $MaxHeight) {
                        [double]$MaxWidth / $originalImage.Width
                    } else {
                        [Math]::Min(([double]$MaxWidth / $originalImage.Width), ([double]$MaxHeight / $originalImage.Height))
                    }
                    $newWidth = [int]($originalImage.Width * $ratio)
                    $newHeight = [int]($originalImage.Height * $ratio)
                }
            }
            
            $resizedImage = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($resizedImage)
            $graphics.SmoothingMode = $SmoothingMode
            $graphics.InterpolationMode = $InterpolationMode
            $graphics.PixelOffsetMode = $PixelOffsetMode
            $graphics.DrawImage($originalImage, 0, 0, $newWidth, $newHeight)
            
            if (-not $DisableEXIF) {
                foreach ($propItem in $originalImage.PropertyItems) { $resizedImage.SetPropertyItem($propItem) }
            }
            
            $imageFormat = switch ($Format.ToLower()) {
                'png'   { [System.Drawing.Imaging.ImageFormat]::Png }
                'gif'   { [System.Drawing.Imaging.ImageFormat]::Gif }
                'bmp'   { [System.Drawing.Imaging.ImageFormat]::Bmp }
                'tiff'  { [System.Drawing.Imaging.ImageFormat]::Tiff }
                default { [System.Drawing.Imaging.ImageFormat]::Jpeg }
            }
            $resizedImage.Save($finalOutFile, $imageFormat)
            [System.IO.File]::SetCreationTime($finalOutFile, $creationTime)
            [System.IO.File]::SetLastWriteTime($finalOutFile, $lastWriteTime)
            
            Write-Host "Completed: $([System.IO.Path]::GetFileName($finalOutFile))"
            $graphics.Dispose()
            $resizedImage.Dispose()
            $originalImage.Dispose()
        } catch {
            Write-Error "Error resizing image: $_"
        }
    }
}
