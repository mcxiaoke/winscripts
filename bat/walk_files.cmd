@echo off
setlocal enabledelayedexpansion

REM ��ȡ����Ŀ¼
set /p input_dir="������Ŀ¼·��: "

REM ����ű�Ŀ¼
set "script_dir=%~dp0"
echo �ű�Ŀ¼: %script_dir%

REM �����ǰĿ¼
echo ��ǰĿ¼: %CD%

REM �ݹ����Ŀ¼
for /r "%input_dir%" %%F in (*) do (
    REM ����ļ�����·��
    echo ����·��: %%F

    REM ��ȡ�ļ��ĸ�Ŀ¼
    for %%P in ("%%~dpF\.") do (
        set "parent_dir=%%~fP"
    )
    echo ��Ŀ¼: !parent_dir!

    REM ��ȡ�ļ���
    set "file_name=%%~nxF"
    echo �ļ���: !file_name!

    REM ��ȡ����չ�����ļ���
    set "file_name_with_extension=%%~nxF"
    echo ����չ�����ļ���: !file_name_with_extension!

    REM ��ȡ������չ�����ļ���
    set "file_name_without_extension=%%~nF"
    echo ������չ�����ļ���: !file_name_without_extension!

    echo.
)
