@echo off

rem ����Ƿ��ṩ��Ŀ¼����
if "%~1"=="" (
    echo ���ṩĿ¼·����Ϊ������
    exit /b 1
)

rem ���ò���ΪҪ�����Ŀ¼
set "root_dir=%~1"

echo �ű�·����%~dp0

rem �ݹ����Ŀ¼
for /r "%root_dir%" %%F in (*) do (
    set "current_path=%%~dpF"
    set "item_type="

    rem �ж����ļ�����Ŀ¼
    if exist "%%F\" (
        set "item_type=Ŀ¼"
    ) else (
        set "item_type=�ļ�"
    )

    rem �����Ϣ

    echo ���ͣ�%item_type%
    echo ����·����%%F
    echo �ļ�����%%~nxF
    echo �ļ���������չ����%%~nF
    echo �ļ���չ����%%~xF
    echo.
)

exit /b
