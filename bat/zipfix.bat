@echo off
setlocal enabledelayedexpansion
echo =======================================
echo -
echo ZipFixС����
echo ������ 2024.04.06
echo ʹ��ZipUnicode���޸��ļ�������
echo �ݹ����Ŀ¼���޸����ѹZIP�ļ�
echo ʹ��UTF8���봴����ZIP�ļ�
echo �÷��� zipfix �ļ�Ŀ¼ [ָ������]
echo -
echo =======================================

rem ����Ƿ��ṩ��Ŀ¼����
if "%~1"=="" (
    echo ���ṩĿ¼·����Ϊ����
    exit /b 1
)

rem ���ò���ΪҪ�����Ŀ¼
rem ��������Ŀ¼����·��
set "root_dir=%~f1"
set "encoding=%2"

echo �ű�·����%~dp0
echo ����Ŀ¼��"%root_dir%"

rem ��ʾ�û�ѡ��
echo ��ѡ��Ҫִ�еĲ�����
echo 1. ȡ�����˳�
echo 2. ��ѹZIP�ļ�
echo 3. �޸�ZIP�ļ�
echo 4. ���ZIP�ļ�
set /p option=�����������ţ�

rem ����û�����
if "%option%"=="1" (
    echo �û�ȡ����ִֹͣ�к�������
    exit /b
) else if "%option%"=="2" (
    echo �û�ѡ���ѹ����
) else if "%option%"=="3" (
    echo �û�ѡ���޸�����
) else if "%option%"=="4" (
    echo �û�ѡ�������
) else (
    echo ������Ч�������������� 1��2��3 �� 4��
    exit /b
)

set /p user_encoding=ָ���ļ������룺

if  defined user_encoding  (
	set encoding="!user_encoding!"
) 

if "!encoding!" neq "" (
echo �ļ������룺!encoding!
)

rem ��ʾ�û�ȷ��
set /p confirm=ȷ��ִ�к���������(���� y��yes ȷ��)
if /i not "%confirm%"=="y" (
    if /i not "%confirm%"=="yes" (
        echo �û�ȡ����ִֹͣ�к�������
        exit /b
    )
)

rem �ݹ����Ŀ¼
for /r "%root_dir%" %%F in (*.zip) do (
    set "current_path=%%~dpF"
	set "fileName=%%~nxF"
	set "nameNoExt=%%~nF"
    rem ����ļ����Ƿ��� "_fixed" ��β�������������
    if /i "!nameNoExt:~-6!"=="_fixed" (
        echo �����ļ� "!fileName!"
    ) else (
	    rem echo �����ļ� %%F
		rem ��ѹ�ļ���ͬ��Ŀ¼
		pushd "!current_path!"
		if "!option!"=="2" (
			echo ��ѹ�ļ� "%%F"
			if "!encoding!" == "" (
				zipu --extract "!fileName!"
			) else (
				zipu --encoding !encoding! --extract "!fileName!"
			)
		) else if "!option!"=="3" (
		set "nameFixed=!nameNoExt!_fixed.zip"
		set "fileFixed=!current_path!!nameFixed!"
			if  exist "!fileFixed!" (
				echo �ļ��Ѵ��� "!nameFixed!"
			) else (
				echo �޸��ļ� "%%F"
				if "!encoding!" == "" (
					zipu --fix "!fileName!"
				) else (
					zipu --encoding !encoding! --fix "!fileName!"
				)			
			)
		) else if "!option!"=="4" (
			echo ����ļ� "%%F"
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
    REM echo %%a���ļ�������Ϣ
    REM echo %%~da�������ļ�������������Ϣ
    REM echo %%~pa�������ļ�����·����Ϣ
    REM echo %%~na�������ļ�����Ϣ
    REM echo %%~xa�������ļ���׺��Ϣ
    REM echo %%~za�������ļ���С��Ϣ
    REM echo %%~ta�������ļ��޸�ʱ����Ϣ
    REM echo %%~dpa�������ļ�����������������·����Ϣ
    REM echo %%~nxa�������ļ�������׺��Ϣ
    REM echo %%~pnxa�������ļ�����·�����ļ����ͺ�׺��Ϣ
    REM echo %%~dpna�������ļ���������·�����ļ�����Ϣ
    REM echo %%~dpnxa�������ļ���������·�����ļ�������׺��Ϣ
REM )