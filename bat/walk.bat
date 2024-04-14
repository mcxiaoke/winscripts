@echo off
setlocal enabledelayedexpansion

set "root_dir=%~1"

rem 遍历目录并将结果保存到临时文件
set "temp_file=%temp%\zip_list.tmp"
dir /s /b "%root_dir%\*.m4a" > "%temp_file%"

rem 检查是否有待解压的 ZIP 文件
if not exist "%temp_file%" (
    echo 没有找到 ZIP 文件
    exit /b 1
)

rem 遍历临时文件中的每一个 ZIP 文件并解压
for /f "usebackq delims=" %%F in ("%temp_file%") do (
    echo 开始解压文件：%%F
)

rem 删除临时文件
rem del "%temp_file%"

endlocal
exit /b
