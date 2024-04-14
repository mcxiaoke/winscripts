@echo off
setlocal enabledelayedexpansion

rem ����FFmpeg·��
set ffmpeg_path="ffmpeg.exe"

rem ��ȡ�����в�����ΪĿ���ļ���
set target_folder=%1

rem ����Ƿ��ṩ��Ŀ���ļ��в���
if "%target_folder%"=="" (
    echo ���ṩĿ���ļ���·����Ϊ�����в�����
    exit /b
)

rem ���Ŀ���ļ����Ƿ����
if not exist "%target_folder%" (
    echo �ṩ��Ŀ���ļ���·�������ڡ�
    exit /b
)

rem �ݹ�����ļ���
for /r "%target_folder%" %%i in (*.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm) do (
    rem ����ļ��������Ƿ��� "_shana" ��β�����������������
    echo %%~ni | findstr /i "_shana" 
    if !errorlevel! equ 0 (
        echo �����ļ�: %%i
    ) else (
		rem ��ȡ�ļ�·�����ļ���
		set "input_filepath=%%i"
		set "temp_filepath=%%~dpi%%~ni_tmp.mp4"
		set "output_filepath=%%~dpi%%~ni_shana.mp4"
		
		echo �����ļ� !input_filepath!
		rem ѹ����Ƶ�ļ��������ٶȣ����浽ԭ�ļ�ͬһĿ¼
		%ffmpeg_path% -hide_banner -i "!input_filepath!" -filter_complex "[0:v]setpts=PTS/1.5, scale=w=min(iw\,1080):h=min(ih\,1080)[v];[0:a]atempo=1.5[a]" -map "[v]" -map "[a]" -c:v hevc_nvenc -bufsize 2000k -maxrate 500k -cq 23 -c:a libfdk_aac -profile:a aac_he -b:a 48k "!temp_filepath!" && (
			echo ת���ɹ���������Ϊָ�����ļ���
			echo FROM !temp_filepath!
			echo TO !output_filepath!
			move "!temp_filepath!" "!output_filepath!"
		) || (
			echo ת��ʧ�ܣ�ɾ����ʱ�ļ�
			echo DEL !temp_filepath!
			del "!temp_filepath!"
		)
    )
)
