@echo off

rem 检查是否提供了目录参数
if "%~1"=="" (
    echo 请提供目录路径作为参数。
    exit /b 1
)

rem 设置参数为要处理的目录
set "root_dir=%~1"

echo 脚本路径：%~dp0

rem 递归遍历目录
for /r "%root_dir%" %%F in (*) do (
    set "current_path=%%~dpF"
    set "item_type="

    rem 判断是文件还是目录
    if exist "%%F\" (
        set "item_type=目录"
    ) else (
        set "item_type=文件"
    )

    rem 输出信息

    echo 类型：%item_type%
    echo 完整路径：%%F
    echo 文件名：%%~nxF
    echo 文件名不带扩展名：%%~nF
    echo 文件扩展名：%%~xF
    echo.
)

exit /b
