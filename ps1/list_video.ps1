# /*
# * Project: ps1
# * Created: 2024-04-14 18:19:38
# * Modified: 2024-04-14 18:19:38
# * Author: mcxiaoke (github@mcxiaoke.com)
# * License: Apache License 2.0
# */

param (
    [string]$directoryPath
)

# 检查输入的目录是否存在
if (-not (Test-Path $directoryPath -PathType Container)) {
    Write-Host "目录不存在或不可访问: $directoryPath"
    exit
}

# 创建可变大小的数组
$outputArray = New-Object System.Collections.ArrayList

# 递归遍历目录
function RecurseDirectory ($dir) {
    # 获取目录中的所有文件
    $files = Get-ChildItem -Path $dir -File

    # 遍历每个文件
    foreach ($file in $files) {
        # 检查文件是否为视频文件
        if ($file.Extension -match '\.(mp4|mkv|avi|mov|ts|wmv|flv|webm)$') {
            # 获取视频文件的分辨率和码率
            $mediaInfo = & ffprobe.exe -v error -select_streams v:0 -show_entries "stream=codec_name,width,height,bit_rate" -of csv=p=0 $file.FullName
            $codecName, $width, $height, $bitRate, $dummy = $mediaInfo -split ','
            Write-Host "File: $file"
            Write-Host "Info: $mediaInfo"

            # 提取字符串中的数字
            $bitRate = $bitRate -replace '[^\d.]'
            # 检查是否有非法值
            if ($bitRate -eq '') {
                $bitRate = "0"
            }

            # 获取原始文件名和扩展名
            $oldFileName = $file.Name
            $extension = $file.Extension
            $baseName = $oldFileName -replace $extension
            
            # 创建带有分辨率后缀的新文件名
            $newFileName = "${baseName}_${codecName}_${width}x${height}$extension"

            if (-not ($oldFileName -match "_${width}x${height}$extension$")) {
                # 如果新文件名与原文件名不同，进行重命名操作
                if ($newFileName -ne $oldFileName) {
                    #Rename-Item -Path $file.FullName -NewName $newFileName
                    Write-Host "Renamed: $newFileName"
                }
            }
            else { 
                Write-Host "Ignore: $oldFileName"
            }

            # 创建一个对象来存储文件信息
            $fileInfo = New-Object PSObject -Property @{
                FileName   = $file.Name
                FileType   = $codecName
                FileSize   = $file.Length
                Resolution = "$width x $height"
                BitRate    = [int]($bitRate.Trim())
            }

            # 将文件信息添加到输出数组
            $outputArray.Add($fileInfo) | Out-Null
        }
    }

    # 获取子目录并递归调用
    $subDirectories = Get-ChildItem -Path $dir -Directory
    foreach ($subDir in $subDirectories) {
        RecurseDirectory $subDir.FullName
    }
}

# 递归调用
RecurseDirectory $directoryPath

# 按照分辨率从高到低，码率从高到低排序
$outputArray = $outputArray | Sort-Object @{Expression = { [int]($_.Resolution -replace '(\d+) x (\d+)', '$1') }; Descending = $true }, @{Expression = { $_.BitRate }; Descending = $true }

# 输出到控制台
$outputArray | Format-Table -AutoSize

# 保存到文本文件
$outputArray | Export-Csv -Path "$directoryPath\VideoFileInfo.txt" -NoTypeInformation
