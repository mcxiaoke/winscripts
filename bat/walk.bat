@echo off
setlocal enabledelayedexpansion

set "root_dir=%~1"

rem ����Ŀ¼����������浽��ʱ�ļ�
set "temp_file=%temp%\zip_list.tmp"
dir /s /b "%root_dir%\*.m4a" > "%temp_file%"

rem ����Ƿ��д���ѹ�� ZIP �ļ�
if not exist "%temp_file%" (
    echo û���ҵ� ZIP �ļ�
    exit /b 1
)

rem ������ʱ�ļ��е�ÿһ�� ZIP �ļ�����ѹ
for /f "usebackq delims=" %%F in ("%temp_file%") do (
    echo ��ʼ��ѹ�ļ���%%F
)

rem ɾ����ʱ�ļ�
rem del "%temp_file%"

endlocal
exit /b
