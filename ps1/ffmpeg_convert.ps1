# /*
# * Project: ps1
# * Created: 2024-04-18 16:23:27
# * Modified: 2024-04-18 16:23:27
# * Author: mcxiaoke (github@mcxiaoke.com)
# * License: Apache License 2.0
# */


param (
    [string]$Directory,
    [string]$VideoBitrate = "2000k",
    [string]$AudioBitrate = "128k",
    [string[]]$Extensions = @(".mp4", ".mkv", ".avi", ".mov"),
    [string]$OutputDirectory = $null,
    [string]$IgnoreSHANA,
    [float]$Speed = 1,
    [string]$MaxResolution = "1920x1080"
)

$OUTPUT_PREFIX = "[SHANA] "

function ShortenPath {
    param (
        [string]$inputString,
        [int]$length = 60
    )

    # 检查输入字符串的长度是否超过指定的长度
    if ($inputString.Length -le $length) {
        return $inputString
    }

    # 计算截取的起始索引
    $startIndex = $inputString.Length - $length

    # 如果计算得到的起始索引小于 0，则将其调整为 0
    if ($startIndex -lt 0) {
        $startIndex = 0
    }

    # 截取字符串
    $result = $inputString.Substring($startIndex, $length)

    return "..." + $result
}


function Convert-VideoToMP4 {
    param (
        [string]$FilePath,
        [string]$OutputFileName,
        [string]$VideoBitrate,
        [string]$AudioBitrate,
        [float]$Speed,
        [string]$MaxResolution
    )

    Write-Host "Processing file '$(ShortenPath $FilePath)'"  -ForegroundColor Green 
    Write-Host "With options: [speed=$Speed, res=$MaxResolution, vbit=${VideoBitrate}, abit=${AudioBitrate}]"

    # -replace 是正则，特殊字符如[?\需要转义
    # $escapedPrefix = [regex]::Escape($OUTPUT_PREFIX)
    # $OutputNoPrefix = $OutputFileName -replace $escapedPrefix, ""
    # Replace方法是直接字符串替换
    $OutputFileNameNoPrefix = $OutputFileName.Replace($OUTPUT_PREFIX, "")
    $ShanaOutputFileName = $OutputFileNameNoPrefix -replace ".mp4", "_shana.mp4"
    $TempOutputFileName = $OutputFileName -replace ".mp4", "_tmp.mp4"

    # Write-Host $ShanaOutputFileName "Exists=$(Test-Path -LiteralPath $ShanaOutputFileName)"
    # Write-Host $OutputFileName "Exists=$(Test-Path -LiteralPath $OutputFileName)"
    # Write-Host $TempOutputFileName "Exists=$(Test-Path -LiteralPath $TempOutputFileName)"

    # 路径中有特殊字符，所以要用 -LiteralPath
    if (Test-Path -LiteralPath $ShanaOutputFileName) {
        Write-Host "Skip exists1: $ShanaOutputFileName"
        return
    }
    if (Test-Path -LiteralPath $OutputFileName) {
        Write-Host "Skip exists2: $OutputFileName"
        return
    }

    if (Test-Path -LiteralPath $TempOutputFileName) {
        Write-Host "Remove tempfile: $TempOutputFileName"
        Remove-Item -LiteralPath "$TempOutputFileName" -Force
    }

    # https://www.ffmpeg.org/doxygen/6.0/group__metadata__api.html
    # https://wiki.multimedia.cx/index.php/FFmpeg_Metadata
    # 压缩视频文件并调整速度，保存到原文件同一目录
    # 直接传传参数给ffmpeg会报错

    $ffmpegCommand = "ffmpeg -hide_banner -v error -i `"$FilePath`" -filter_complex `"[0:v]setpts=PTS/$Speed,scale=w=min(iw\,1080):h=min(ih\,1080)[v];[0:a]atempo=$Speed[a]`" -map `[v]` -map `[a]` -c:v hevc_nvenc -profile:v main -cq 23 -tune:v hq -bufsize $VideoBitrate -maxrate $VideoBitrate -c:a libfdk_aac -b:a $AudioBitrate -movflags +faststart `"$TempOutputFileName`""
    $null = $ffmpegCommand

    # $CmdOutput = Invoke-Expression $ffmpegCommand
    $CmdOutput = & ffmpeg -hide_banner -v error -i "$FilePath" -filter_complex "[0:v]setpts=PTS/$Speed,scale=w=min(iw\,1080):h=min(ih\,1080)[v];[0:a]atempo=$Speed[a]" -map [v] -map [a] -c:v hevc_nvenc -profile:v main -cq 23 -tune:v hq -bufsize $VideoBitrate -maxrate $VideoBitrate -c:a libfdk_aac -b:a $AudioBitrate -movflags +faststart "$TempOutputFileName"

    if ($LastExitCode -eq 0) {
        Write-Host "Output: $OutputFileName."
        Rename-Item -Path $TempOutputFileName -NewName $OutputFileName -Force
        Write-Host $CmdOutput
    }
    else {
        Write-Host "Failed: remove temp file."
        Remove-Item -LiteralPath $TempOutputFileName -ErrorAction SilentlyContinue
    }
}

function Get-OutputFileName {
    param (
        [string]$FilePath,
        [string]$OutputDir = $Script:OutputDirectory
    )
    $OutputDirectory = $OutputDir
    if (-not $OutputDirectory) {
        $OutputDirectory = [System.IO.Path]::GetDirectoryName($FilePath)
    }
    $OutputFileName = Join-Path -Path $OutputDirectory -ChildPath "$OUTPUT_PREFIX$([System.IO.Path]::GetFileNameWithoutExtension($FilePath)).mp4"
    return $OutputFileName
}

# 递归遍历文件夹
function Get-FilesRecursively {
    param (
        [string]$FolderPath
    )

    # 获取文件夹下所有文件和子文件夹
    $items = Get-ChildItem -Path $FolderPath

    foreach ($item in $items) {
        # 如果是文件夹，则递归调用本函数
        if ($item.PSIsContainer) {
            Get-FilesRecursively -FolderPath $item.FullName
        }
        else {
            $item.FullName  # 输出文件路径
        }
    }
}

# 过滤指定扩展名的文件
function Find-ByExtension {
    param (
        [string[]]$FilePaths,
        [string[]]$Extensions
    )

    $filteredFiles = @()

    foreach ($file in $FilePaths) {
        $extension = [System.IO.Path]::GetExtension($file)
        if ($Extensions -contains $extension) {
            $filteredFiles += $file  # 添加符合条件的文件路径到数组
        }
    }

    return $filteredFiles
}

# 过滤文件名不含指定字符串的文件
function Find-ByString {
    param (
        [string[]]$FilePaths,
        [string]$FilterString
    )

    $filteredFiles = @()

    foreach ($file in $FilePaths) {
        if ($file -notmatch $FilterString) {
            $filteredFiles += $file  # 添加符合条件的文件路径到数组
        }
    }

    return $filteredFiles
}

function Get-VideoFiles {
    param (
        [string]$Path,
        [string[]]$Extensions
    )

    $FilesInFolder = Get-FilesRecursively -FolderPath $Path
    $VideoInFolder = Find-ByExtension -FilePaths $FilesInFolder -Extensions $Extensions
    $VideoInFolder = Find-ByString -FilePaths $VideoInFolder -FilterString "shana"

    return $VideoInFolder  # 返回符合条件的视频文件路径数组
}


# 函数调用

if (-not $IgnoreSHANA) {
    $IgnoreSHANA = $true
}
$VideoFiles = Get-VideoFiles -Path $Directory -Extensions $Extensions
if ($VideoFiles.Count -eq 0) {
    Write-Host "No video files found in: $Directory"
    exit
}
foreach ($File in $VideoFiles) {
    $OutputFileName = Get-OutputFileName -FilePath $File -OutputDir $Script:OutputDirectory
    Convert-VideoToMP4 -FilePath $File -OutputFileName $OutputFileName -VideoBitrate $VideoBitrate -AudioBitrate $AudioBitrate -Speed $Speed -MaxResolution $MaxResolution
}