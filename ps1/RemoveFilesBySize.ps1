#### functions added at 2024
function RemoveFilesBySize {
    param(
        [string]$DirectoryPath,
        [int]$SizeThresholdKB,
        [bool]$DryRun = $false,
        [switch]$Help
    )

    # 定义帮助文档
    <#
.SYNOPSIS
Remove files by size parameter from a directory recursively.

.DESCRIPTION
This function removes files smaller than a specified size threshold from a directory and its subdirectories.

.PARAMETER DirectoryPath
Specifies the directory path to start the search for small files.

.PARAMETER SizeThresholdKB
Specifies the size threshold in kilobytes. Files smaller than this threshold will be removed.

.PARAMETER DryRun
Specifies whether to perform a dry run. When set to true, the function only prints the files to be removed without actually deleting them.

.PARAMETER Help
Display the help message.

.EXAMPLE
RemoveFilesBySize -DirectoryPath "C:\Your\Directory\Path" -SizeThresholdKB 100
Recursively removes files smaller than 100KB from the specified directory.

.EXAMPLE
RemoveFilesBySize -DirectoryPath "C:\Your\Directory\Path" -SizeThresholdKB 100 -DryRun
Performs a dry run to display the files that would be removed without actually deleting them.

#>

    # 检查是否提供了 -Help 或 --help 参数，如果提供则显示帮助信息
    if ($MyInvocation.BoundParameters.ContainsKey('Help')) {
        Get-Help RemoveFilesBySize
    }

    # 检查是否提供了必要参数，如果没有则显示帮助信息
    if (-not $MyInvocation.BoundParameters.ContainsKey('DirectoryPath') -or -not $MyInvocation.BoundParameters.ContainsKey('SizeThresholdKB')) {
        Write-Host "Error: DirectoryPath and SizeThresholdKB are required."
        Get-Help RemoveFilesBySize
    }

    # 如果提供了 -Help 参数，则显示帮助信息
    if ($Help) {
        Get-Help RemoveFilesBySize
        return
    }

    # 检查是否提供了必要参数
    if (-not $DirectoryPath -or -not $SizeThresholdKB) {
        Write-Host "Error: DirectoryPath and SizeThresholdKB are required."
        Get-Help RemoveFilesBySize
        return
    }

    # 获取目录中所有文件
    $files = Get-ChildItem -Path $DirectoryPath -File

    # 遍历每个文件
    foreach ($file in $files) {
        # 如果文件大小小于阈值，则删除文件或打印信息
        if ($file.Length -lt $SizeThresholdKB * 1kb) {
            if ($DryRun) {
                Write-Host "File to be removed (dry run): $($file.FullName)"
            }
            else {
                Remove-Item -Path $file.FullName -Force
                Write-Host "Removed file: $($file.FullName)"
            }
        }
    }

    # 获取目录中的子目录
    $subDirectories = Get-ChildItem -Path $DirectoryPath -Directory

    # 递归调用 RemoveFilesBySize 函数，处理每个子目录
    foreach ($subDirectory in $subDirectories) {
        RemoveFilesBySize -DirectoryPath $subDirectory.FullName -SizeThresholdKB $SizeThresholdKB -DryRun $DryRun
    }
}

RemoveFilesBySize
