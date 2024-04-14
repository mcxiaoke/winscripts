@echo off
setlocal enabledelayedexpansion

REM 读取输入目录
set /p input_dir="请输入目录路径: "

REM 输出脚本目录
set "script_dir=%~dp0"
echo 脚本目录: %script_dir%

REM 输出当前目录
echo 当前目录: %CD%

REM 递归遍历目录
for /r "%input_dir%" %%F in (*) do (
    REM 输出文件完整路径
    echo 完整路径: %%F

    REM 获取文件的父目录
    for %%P in ("%%~dpF\.") do (
        set "parent_dir=%%~fP"
    )
    echo 父目录: !parent_dir!

    REM 获取文件名
    set "file_name=%%~nxF"
    echo 文件名: !file_name!

    REM 获取带扩展名的文件名
    set "file_name_with_extension=%%~nxF"
    echo 带扩展名的文件名: !file_name_with_extension!

    REM 获取不带扩展名的文件名
    set "file_name_without_extension=%%~nF"
    echo 不带扩展名的文件名: !file_name_without_extension!

    echo.
)
