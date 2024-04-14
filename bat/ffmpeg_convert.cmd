@echo off
setlocal enabledelayedexpansion

rem 设置FFmpeg路径
set ffmpeg_path="ffmpeg.exe"

rem 获取命令行参数作为目标文件夹
set target_folder=%1

rem 检查是否提供了目标文件夹参数
if "%target_folder%"=="" (
    echo 请提供目标文件夹路径作为命令行参数。
    exit /b
)

rem 检查目标文件夹是否存在
if not exist "%target_folder%" (
    echo 提供的目标文件夹路径不存在。
    exit /b
)

rem 递归遍历文件夹
for /r "%target_folder%" %%i in (*.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm) do (
    rem 检查文件基本名是否以 "_shana" 结尾，如果是则跳过处理
    echo %%~ni | findstr /i "_shana" 
    if !errorlevel! equ 0 (
        echo 跳过文件: %%i
    ) else (
		rem 获取文件路径和文件名
		set "input_filepath=%%i"
		set "temp_filepath=%%~dpi%%~ni_tmp.mp4"
		set "output_filepath=%%~dpi%%~ni_shana.mp4"
		
		echo 处理文件 !input_filepath!
		rem 压缩视频文件并调整速度，保存到原文件同一目录
		%ffmpeg_path% -hide_banner -i "!input_filepath!" -filter_complex "[0:v]setpts=PTS/1.5, scale=w=min(iw\,1080):h=min(ih\,1080)[v];[0:a]atempo=1.5[a]" -map "[v]" -map "[a]" -c:v hevc_nvenc -bufsize 2000k -maxrate 500k -cq 23 -c:a libfdk_aac -profile:a aac_he -b:a 48k "!temp_filepath!" && (
			echo 转换成功，重命名为指定的文件名
			echo FROM !temp_filepath!
			echo TO !output_filepath!
			move "!temp_filepath!" "!output_filepath!"
		) || (
			echo 转换失败，删除临时文件
			echo DEL !temp_filepath!
			del "!temp_filepath!"
		)
    )
)
