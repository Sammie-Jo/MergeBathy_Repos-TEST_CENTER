::::
:: verify.bat
:: Created by Samantha Zambo
:: Dec 10, 2014
:: 
:: This batch script will verify output results by comparing with previously generated output files.
::
:: Requirements:
:: 	Either Leave the directory unchanged 
:: 	or modify all paths here and in respective files.
::
:: ::


@echo off
set bitModeID=3
set configModeID=3
set /p bitModeID="Select (1) 32bit (2) 64bit (3) both : " 
set /p configModeID="Select (1) Debug (2) Release (3) both : "
set oldConfigModeID=0
set bitErrFlag=1
set configErrFlag=1
if exist ".\verification_results.txt" del ".\verification_results.txt"

:runMe
	if %configModeID%==3 (
		set configFolder=Debug
		set configErrFlag=0
	)
	if %configModeID%==1 ( 
		set configFolder=Debug
		set configErrFlag=0
	)
	if %configModeID%==2 (
		set configFolder=Release
		set configErrFlag=0
	)
	if %configErrFlag%==1 (
		echo "Invalid configuration selection. Exit."
		goto:endRun
	)
	if %bitModeID%==3 (
		set bitFolder=x86
		set bitErrFlag=0
	)
	if %bitModeID%==1 (
		set bitFolder=x86
		set bitErrFlag=0
	)
	if %bitModeID%==2 (
		set bitFolder=x64
		set bitErrFlag=0
	)
	if %bitErrFlag%==1 (
		echo "Invalid bit selection. Exit."
		goto:endRun
	)

	if not exist "..\output_files\%bitFolder%\%configFolder%" (
		echo Verification Failed: No output files were generated! 
		echo ..\output_files\%bitFolder%\%configFolder% Does not exist or is empty.
	)
	if not exist "..\output_files_win\%bitFolder%\%configFolder%" (
		echo Verification Failed: Original Window output files are needed to verify!
		echo ..\output_files_win\%bitFolder%\%configFolder% Does not exist or is empty.
	)

	fc /W /N "..\output_files\%bitFolder%\%configFolder%\*" "..\output_files_win\%bitFolder%\%configFolder%\*" >> verification_results.txt
		
	if %configModeID%==3 (
		set configModeID=2
		set oldConfigModeID=3
		goto:runMe
	)
	if %bitModeID%==3 (
		set configModeID=1
		set bitModeID=2 
		if %oldConfigModeID%==3 set configModeID=3
		goto:runMe
	)
	::cls
	echo.
	echo verify.bat done.
	goto:endRun

:endRun
	pause

