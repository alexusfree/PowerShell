## Изменение размера изображений на PowerShell
Этот скрипт на PowerShell предоставляет функцию для изменения размера изображений с сохранением пропорций. Скрипт может обрабатывать как один файл, так и несколько файлов через конвейер.

### Требования
* **PowerShell:** Для работы скрипта требуется PowerShell.
* **.NET Framework:** Требуется сборка `System.Drawing`, которая является частью .NET Framework.

### Возможности
* **Изменение размера:** Масштабирование изображений до указанной максимальной ширины или высоты.
* **Сохранение пропорций:** Автоматически сохраняет соотношение сторон, для отключения `-DisableRatio`.
* **Конвертация формата:** Сохранение измененного изображения в другом формате (`.jpg`, `.png`, `.gif`, `.bmp`, `.tiff`).
* **Сохранение метаданных:** По умолчанию сохраняет исходные метаданные файла (данные EXIF и временные метки). для отключения -DisableEXIF
* **Пакетная обработка:** Может обрабатывать все файлы изображений в каталоге или получать их через конвейер.
* **Настройка качества:** По умолчанию используется наилучшее качество при масштабировании. 

#### -InterpolationMode
Определяет алгоритм, используемый для изменения размера изображений.  По умолчанию используется HighQualityBicubic наилучшее качество при масштабировании, но может быть медленнее других режимов.
`Default | Low | High | Bilinear | Bicubic | NearestNeighbor | HighQualityBilinear | HighQualityBicubic`

#### -SmoothingMode
Управляет сглаживанием линий и кривых при отрисовке. Значение по умолчанию — HighQuality, что обеспечивает высокое качество визуализации.
`Default | HighSpeed | HighQuality | None | AntiAlias`

#### -PixelOffsetMode
Задает, как пиксели смещаются при отрисовке, чтобы избежать "дребезжания" и обеспечить более четкие границы. По умолчанию установлен HighQuality.
`Default | HighSpeed | HighQuality | None | Half`

### Как использовать
  1.  **Сохраните скрипт:** Сохраните код как `Resize-Image.ps1`.
  2.  **Импортируйте функцию:** В сеансе PowerShell выполните `Import-Module .\Resize-Image.ps1`.
  3.  **Выполните команду:** Используйте функцию `Resize-Image` с нужными параметрами.

### SYNTAX
    Resize-Image [-InputPath] <Object> [-OutputPath] <String> [[-Format] <String>] [[-MaxWidth] <Int32>] [[-MaxHeight]
    <Int32>] [[-SmoothingMode] {Default | HighSpeed | HighQuality | None | AntiAlias}] [[-InterpolationMode]
    {Default | Low | High | Bilinear | Bicubic | NearestNeighbor | HighQualityBilinear | HighQualityBicubic}]
    [[-PixelOffsetMode] {Default | HighSpeed | HighQuality | None | Half}] [-DisableRatio] [-DisableEXIF] 
    [<CommonParameters>]
    
Справка в powershell
`Get-Help Resize-Image -Full`

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
Resize-Image -InputPath "C:\Images" -OutputPath "C:\Images\small\photo.png" -Format JPG -DisableEXIF 
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

