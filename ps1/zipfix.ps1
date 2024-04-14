# /*
# * Project: ps1
# * Created: 2024-04-14 16:55:11
# * Modified: 2024-04-14 16:55:11
# * Author: mcxiaoke (github@mcxiaoke.com)
# * License: Apache License 2.0
# */


Write-Host "======================================="
Write-Host "-"
Write-Host "ZipFix小工具"
Write-Host "创建于 2024.04.06"
Write-Host "使用ZipUnicode库修复文件名乱码"
Write-Host "递归遍历目录，修复或解压ZIP文件"
Write-Host "使用UTF8编码创建新ZIP文件"
Write-Host "用法： zipfix 文件目录 [指定编码]"
Write-Host "-"
Write-Host "======================================="

# 检查是否提供了目录参数
if (-not $args) {
    Write-Host "请提供目录路径作为参数"
    exit 1
}

# 设置参数为要处理的目录
# 设置输入目录绝对路径
$root_dir = $args[0]
$encoding = $args[1]

Write-Host "脚本路径：$PSScriptRoot"
Write-Host "输入目录：""$root_dir"""

# 提示用户选择
Write-Host "请选择要执行的操作："
Write-Host "1. 取消并退出"
Write-Host "2. 解压ZIP文件"
Write-Host "3. 修复ZIP文件"
Write-Host "4. 检查ZIP文件"
$option = Read-Host "请输入操作序号："

# 检查用户输入
if ($option -eq "1") {
    Write-Host "用户取消，停止执行后续处理。"
    exit
}
elseif ($option -eq "2") {
    Write-Host "用户选择解压操作"
}
elseif ($option -eq "3") {
    Write-Host "用户选择修复操作"
}
elseif ($option -eq "4") {
    Write-Host "用户选择检查操作"
}
else {
    Write-Host "输入无效，请输入操作序号 1、2、3 或 4。"
    exit 1
}

$user_encoding = Read-Host "指定文件名编码："

if ($user_encoding) {
    $encoding = $user_encoding
}

if ($encoding) {
    Write-Host "文件名编码：$encoding"
}

# 提示用户确认
$confirm = Read-Host "确认执行后续操作吗？(输入 y 或 yes 确认)"
if ($confirm -ne "y" -and $confirm -ne "yes") {
    Write-Host "用户取消，停止执行后续处理。"
    exit
}

# 递归遍历目录
Get-ChildItem -Path $root_dir -Recurse -Filter *.zip | ForEach-Object {
    $current_path = $_.DirectoryName
    $fileName = $_.Name
    $nameNoExt = $_.BaseName

    # 检查文件名是否以 "_fixed" 结尾，如果是则跳过
    if ($nameNoExt.EndsWith("_fixed")) {
        Write-Host "忽略文件 ""$fileName"""
    }
    else {
        # 处理文件
        Set-Location $current_path
        if ($option -eq "2") {
            Write-Host "解压文件 ""$fileName"""
            if (-not $encoding) {
                zipu --extract "$fileName"
            }
            else {
                zipu --encoding $encoding --extract "$fileName"
            }
        }
        elseif ($option -eq "3") {
            $nameFixed = $nameNoExt + "_fixed.zip"
            $fileFixed = Join-Path $current_path $nameFixed
            if (Test-Path $fileFixed) {
                Write-Host "文件已存在 ""$nameFixed"""
            }
            else {
                Write-Host "修复文件 ""$fileName"""
                if (-not $encoding) {
                    zipu --fix "$fileName"
                }
                else {
                    zipu --encoding $encoding --fix "$fileName"
                }
            }
        }
        elseif ($option -eq "4") {
            Write-Host "检查文件 ""$fileName"""
            if (-not $encoding) {
                zipu "$fileName"
            }
            else {
                zipu --encoding $encoding "$fileName"
            }
        }
        Set-Location $PSScriptRoot
    }
}
