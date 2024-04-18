# /*
#  * Project: ps1
#  * Created: 2024-04-15 19:45:37
#  * Modified: 2024-04-15 19:45:37
#  * Author: mcxiaoke (github@mcxiaoke.com)
#  * License: Apache License 2.0
#  */

param(
    [string]$sourceDir
)

function UnzipFiles($sourceDir) {
    $files = Get-ChildItem -Path $sourceDir -Filter *.7z, *.rar -Recurse

    foreach ($file in $files) {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
        $destDir = Join-Path -Path $sourceDir -ChildPath $fileName
        $tempDir = $destDir + "_tmp"

        if (-not (Test-Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir | Out-Null

            if ($file.Extension -eq ".7z") {
                7z e $file.FullName -o$tempDir
            }
            elseif ($file.Extension -eq ".rar") {
                unrar x $file.FullName $tempDir
            }

            if ($LASTEXITCODE -eq 0) {
                Rename-Item -Path $tempDir -NewName $fileName -Force
            }
            else {
                Write-Host "Failed to extract $file"
            }
        }
        else {
            Write-Host "$tempDir already exists. Skipping extraction."
        }
    }
}

# 调用函数以递归遍历指定目录
UnzipFiles $sourceDir
