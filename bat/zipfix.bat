@echo off
setlocal enabledelayedexpansion
echo =======================================
echo -
echo ZipFix小工具
echo 创建于 2024.04.06
echo 使用ZipUnicode库修复文件名乱码
echo 递归遍历目录，修复或解压ZIP文件
echo 使用UTF8编码创建新ZIP文件
echo 用法： zipfix 文件目录 [指定编码]
echo -
echo =======================================

rem 检查是否提供了目录参数
if "%~1"=="" (
    echo 请提供目录路径作为参数
    exit /b 1
)

rem 设置参数为要处理的目录
rem 设置输入目录绝对路径
set "root_dir=%~f1"
set "encoding=%2"

echo 脚本路径：%~dp0
echo 输入目录："%root_dir%"

rem 提示用户选择
echo 请选择要执行的操作：
echo 1. 取消并退出
echo 2. 解压ZIP文件
echo 3. 修复ZIP文件
echo 4. 检查ZIP文件
set /p option=请输入操作序号：

rem 检查用户输入
if "%option%"=="1" (
    echo 用户取消，停止执行后续处理。
    exit /b
) else if "%option%"=="2" (
    echo 用户选择解压操作
) else if "%option%"=="3" (
    echo 用户选择修复操作
) else if "%option%"=="4" (
    echo 用户选择检查操作
) else (
    echo 输入无效，请输入操作序号 1、2、3 或 4。
    exit /b
)

set /p user_encoding=指定文件名编码：

if  defined user_encoding  (
	set encoding="!user_encoding!"
) 

if "!encoding!" neq "" (
echo 文件名编码：!encoding!
)

rem 提示用户确认
set /p confirm=确认执行后续操作吗？(输入 y或yes 确认)
if /i not "%confirm%"=="y" (
    if /i not "%confirm%"=="yes" (
        echo 用户取消，停止执行后续处理。
        exit /b
    )
)

rem 递归遍历目录
for /r "%root_dir%" %%F in (*.zip) do (
    set "current_path=%%~dpF"
	set "fileName=%%~nxF"
	set "nameNoExt=%%~nF"
    rem 检查文件名是否以 "_fixed" 结尾，如果是则跳过
    if /i "!nameNoExt:~-6!"=="_fixed" (
        echo 忽略文件 "!fileName!"
    ) else (
	    rem echo 处理文件 %%F
		rem 解压文件到同名目录
		pushd "!current_path!"
		if "!option!"=="2" (
			echo 解压文件 "%%F"
			if "!encoding!" == "" (
				zipu --extract "!fileName!"
			) else (
				zipu --encoding !encoding! --extract "!fileName!"
			)
		) else if "!option!"=="3" (
		set "nameFixed=!nameNoExt!_fixed.zip"
		set "fileFixed=!current_path!!nameFixed!"
			if  exist "!fileFixed!" (
				echo 文件已存在 "!nameFixed!"
			) else (
				echo 修复文件 "%%F"
				if "!encoding!" == "" (
					zipu --fix "!fileName!"
				) else (
					zipu --encoding !encoding! --fix "!fileName!"
				)			
			)
		) else if "!option!"=="4" (
			echo 检查文件 "%%F"
			if "!encoding!" == "" (
				zipu "!fileName!"
			) else (
				zipu --encoding !encoding! "!fileName!"
			)
		)
		popd
	)
)

endlocal
exit /b

  REM for /f %%a in ('dir /s /b a*') do (
    REM echo %%a：文件完整信息
    REM echo %%~da：保留文件所在驱动器信息
    REM echo %%~pa：保留文件所在路径信息
    REM echo %%~na：保留文件名信息
    REM echo %%~xa：保留文件后缀信息
    REM echo %%~za：保留文件大小信息
    REM echo %%~ta：保留文件修改时间信息
    REM echo %%~dpa：保留文件所在驱动器和所在路径信息
    REM echo %%~nxa：保留文件名及后缀信息
    REM echo %%~pnxa：保留文件所在路径及文件名和后缀信息
    REM echo %%~dpna：保留文件驱动器、路径、文件名信息
    REM echo %%~dpnxa：保留文件驱动器、路径、文件名、后缀信息
REM )