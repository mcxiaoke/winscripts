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
elseif ($option -ge "4") {
    Write-Host "输入无效，请输入操作序号 1、2、3 或 4。"
    exit 1
}

# 检查并设置文件名编码
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

# 定义处理函数
function Invoke-ZipUnicode {
    param (
        [string]$FilePath,
        [string]$Option,
        [string]$Encoding
    )

    $CurrentPath = Split-Path -Path $FilePath -Parent
    $FileName = Split-Path -Path $FilePath -Leaf
    $NameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $NameFixed = $NameNoExt + "_fixed.zip"
    $FileFixed = Join-Path -Path $CurrentPath -ChildPath $NameFixed

    if ($NameNoExt.EndsWith("_fixed")) {
        Write-Host "忽略文件 ""$FileName"""
        return
    }

    Set-Location $CurrentPath

    switch ($Option) {
        "2" {
            Write-Host "解压文件 ""$FileName"""
            $zipArgs = @("--extract", $FileName)
        }
        "3" {
            if (Test-Path $FileFixed) {
                Write-Host "文件已存在 ""$NameFixed"""
                return
            }
            Write-Host "修复文件 ""$FileName"""
            $zipArgs = @("--fix", $FileName)
        }
        "4" {
            Write-Host "检查文件 ""$FileName"""
            $zipArgs = @($FileName)
        }
    }

    if ($Encoding) {
        $zipArgs = $zipArgs + @("--encoding", $Encoding)
    }

    zipu @zipArgs

    Set-Location $PSScriptRoot
}

# 递归遍历目录
Get-ChildItem -Path $root_dir -Recurse -Filter *.zip | ForEach-Object {
    Invoke-ZipUnicode -FilePath $_.FullName -Option $option -Encoding $encoding
}
