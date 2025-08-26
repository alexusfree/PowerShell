
[[Readme_ru.md]]

## Resize images with PowerShell
This PowerShell script provides a function to resize images while maintaining aspect ratio. The script can process a single file or multiple files via a pipeline.

### Requirements
* **PowerShell:** PowerShell is required to run the script.
* **.NET Framework:** The `System.Drawing` assembly is required, which is part of the .NET Framework.

### Features
* **Resize:** Scales images to a specified maximum width or height.
* **Preserve aspect ratio:** Automatically preserves aspect ratio, to disable `-DisableRatio`.
* **Convert format:** Saves the resized image in another format (`.jpg`, `.png`, `.gif`, `.bmp`, `.tiff`).
* **Preserve metadata:** By default, preserves the original file metadata (EXIF data and timestamps). To disable -DisableEXIF
* **Batch Processing:** Can process all image files in a directory or receive them via a pipeline.
* **Quality Setting:** Defaults to best quality when scaling.

#### -InterpolationMode
Determines the algorithm used to resize images. Defaults to HighQualityBicubic which provides the best quality when scaling, but may be slower than other modes.
`Default | Low | High | Bilinear | Bicubic | NearestNeighbor | HighQualityBilinear | HighQualityBicubic`

#### -SmoothingMode
Controls the smoothing of lines and curves when rendering. The default is HighQuality, which produces high quality rendering.
`Default | HighSpeed ​​| HighQuality | None | AntiAlias`

#### -PixelOffsetMode
Sets how pixels are offset when drawing to avoid jitter and provide sharper edges. Defaults to HighQuality.
`Default | HighSpeed ​​| HighQuality | None | Half`

### How to use
1. **Save the script:** Save the code as `Resize-Image.ps1`.
2. **Import the function:** In a PowerShell session, run `Import-Module .\Resize-Image.ps1`.
3. **Run the command:** Use the `Resize-Image` function with the desired parameters.

### SYNTAX
    Resize-Image [-InputPath] <Object> [-OutputPath] <String> [[-Format] <String>] [[-MaxWidth] <Int32>] [[-MaxHeight]
    <Int32>] [[-SmoothingMode] {Default | HighSpeed | HighQuality | None | AntiAlias}] [[-InterpolationMode]
    {Default | Low | High | Bilinear | Bicubic | NearestNeighbor | HighQualityBilinear | HighQualityBicubic}]
    [[-PixelOffsetMode] {Default | HighSpeed | HighQuality | None | Half}] [-DisableRatio] [-DisableEXIF] 
    [<CommonParameters>]

`Get-Help Resize-Image -Full`

### Examples
* **Resize a single image to a maximum width of 800px:**
```powershell
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\small\photo_800.jpg" -MaxWidth 800
```

* **Resize all JPG files in a folder and subfolders to a maximum height of 600px:**
```powershell
Get-ChildItem -Path "C:\SourceImages" -Filter "*.jpg", "*.jpeg" -Recurse | Resize-Image -OutputPath "C:\ResizedImages" -MaxHeight 600
```

* **Resize all files to JPG and remove metadata:**
```powershell
Resize-Image -InputPath "C:\Images" -OutputPath "C:\Images\small\photo.png" -Format JPG -DisableEXIF
```

* **Convert image from JPG to PNG without resizing:**
```powershell
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\small\photo.png" -Format png
```
* **Resize all files, `.jpg`, `.png`, `.gif`, `.bmp`, `.tiff` to JPG with renaming the new file:**
```powershell
Get-ChildItem -Path "C:\SourceImages" | ForEach-Object {
Resize-Image -InputPath $_ -OutputPath "$outputDir\Resize_$($_.BaseName)_800-600$($_.Extension)" -MaxWidth 800 -MaxHeight 600 }
```


    


### Примеры
* **Изменение размера одного изображения до максимальной ширины 800px:**
```powershell
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\small\photo_800.jpg" -MaxWidth 800
```

* **Изменение размера всех файлов JPG в папке и подпапках до максимальной высоты 600px:**
```powershell
Get-ChildItem -Path "C:\SourceImages" -Filter "*.jpg", "*.jpeg" -Recurse | Resize-Image -OutputPath "C:\ResizedImages" -MaxHeight 600
```

* **Изменение размера всех файлов в JPG и удаление метаданных:**
```powershell
Resize-Image -InputPath "C:\Images" -OutputPath "C:\Images\small\photo.png" -Format JPG - 
```

* **Конвертация изображения из JPG в PNG без изменения размера:**
```powershell
Resize-Image -InputPath "C:\Images\photo.jpg" -OutputPath "C:\Images\small\photo.png" -Format png
```
* **Изменение размера всех файлов, `.jpg`, `.png`, `.gif`, `.bmp`, `.tiff` в JPG  c переименованием нового файла:**
```powershell
Get-ChildItem -Path "C:\SourceImages" | ForEach-Object { 
Resize-Image -InputPath $_ -OutputPath "$outputDir\Resize_$($_.BaseName)_800-600$($_.Extension)" -MaxWidth 800 -MaxHeight 600 }
```
