::::
:: runInterpTests.bat
:: Created by Samantha J. Zambo
:: Sept 27, 2016
:: 
:: This bash script will test the mergeBathy C++ version on Windows systems.
:: This script will run 4 tests to generate OSP figures.
:: (1) 50 x 50 meter grid with 50 x 50 meter Hann smoothing window
:: (2) 10 x 10 meter grid with 10 x 10 meter Hann smoothing window
:: (3) 10 x 10 meter grid with 20 x 20 meter Hann smoothing window
:: (4) 10 x 10 meter grid with 20 x 100 meter Hann smoothing window
:: (5) 926 x 926 meter grid with 1234.67 x 1234.67 meter Hann smoothing window and pre-splined with 617.33 x 617.33 MB-system zgrid
::
:: Requirements:
:: 	Either Leave the directory unchanged 
:: 	or modify all paths here and in respective files.
::
::::

@echo off
cls
echo.
echo ***********************************************
echo * runInterpTests.bat
echo ***********************************************
echo.
echo.
::=====================================================================
:: Find platform and configuration to test
::SET mPLATFORM=x86
SET mPLATFORM=x64
SET mCONFIGURATION=Debug
::SET mCONFIGURATION=Release

@echo off
set bitModeID=3
set configModeID=3
echo GMT and MBZ will crash in 32bit for large data set.
echo BAG format only available in 32bit.
set /p bitModeID="Select (1) 32bit (2) 64bit (3) both : " 
set /p configModeID="Select (1) Debug (2) Release (3) both : "
set oldConfigModeID=0
set bitErrFlag=1
set configErrFlag=1

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
	set mPLATFORM=%bitFolder%
	set mCONFIGURATION=%configFolder%
	::if [%1] NEQ [] set mPLATFORM=%1
	::if [%2] NEQ [] set mCONFIGURATION=%2
	SET testDir=..\..\..\..\mergeBathy_CPP\%mPLATFORM%\%mCONFIGURATION%
	echo TestingDir: 	
	echo %testDir%
	echo.

	if not exist "..\output_files\%mPLATFORM%\%mCONFIGURATION%" mkdir ..\output_files\%mPLATFORM%\%mCONFIGURATION%
	if not exist "..\command_line_execution\%mPLATFORM%\%mCONFIGURATION%" mkdir ..\command_line_execution\%mPLATFORM%\%mCONFIGURATION%

	if exist ..\output_files\*.txt del ..\output_files\*.txt
	if exist ..\output_files\*.bag del ..\output_files\*.bag
	if exist ..\output_files\*.xml del ..\output_files\*.xml
	if exist ..\output_files\*.asc del ..\output_files\*.asc
	if exist ..\output_files\*.prj del ..\output_files\*.prj
	if exist ..\command_line_execution\*.txt del ..\command_line_execution\*.txt

	:: Assign environment variables
	SET BAG_HOME=%testDir%\..\..\.\configdata
	SET MERGEBATHY_DLLS=%testDir%\..\..\.\extlibs\libs_win\%mPLATFORM%\%mCONFIGURATION%

	:: Set Path variable
	set path= %path%;%MERGEBATHY_DLLS%
	::=====================================================================
	::This is an example input file for demonstrating the capabilites of mergeBathy
	::! 36.177602 -75.749690 18.20 DuckNC mgrid 50 msmooth 50 nooffset plotpts modelflag nonegdepth

	echo TEST CASE 1: Duck, NC 50 x 50 meter grid with 50 x 50 meter Hann smoothing window
	%testDir%\mergeBathy.exe ..\output_files\T10C01_CPP_DUCK_50x50g_50x50s 50 hann ..\..\..\Test_Set_10_OSP_Paper\Active_Testing_Site\input_file_lists\input_file_list_duckExample.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 50 50 -modelflag -nonegdepth > ..\command_line_execution\T10C01_DUCK_50x50g_50x50s_output.txt
	echo ...done.
	echo.
	::pause
	echo TEST CASE 2: Duck, NC 10 x 10 meter grid with 10 x 10 meter Hann smoothing window
	%testDir%\mergeBathy.exe ..\output_files\T10C02_CPP_DUCK_10x10g_10x10s 10 hann ..\..\..\Test_Set_10_OSP_Paper\Active_Testing_Site\input_file_lists\input_file_list_duckExample.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 10 10 -modelflag -nonegdepth > ..\command_line_execution\T10C02_DUCK_10x10g_10x10s_output.txt
	echo ...done.
	echo.
	echo TEST CASE 3: Duck, NC 10 x 10 meter grid with 20 x 20 meter Hann smoothing window
	%testDir%\mergeBathy.exe ..\output_files\T10C03_CPP_DUCK_10x10g_20x20s 10 hann ..\..\..\Test_Set_10_OSP_Paper\Active_Testing_Site\input_file_lists\input_file_list_duckExample.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 20 20 -modelflag -nonegdepth > ..\command_line_execution\T10C03_DUCK_10x10g_20x20s_output.txt
	echo ...done.
	echo.
	echo TEST CASE 4: NC 10 x 10 meter grid with 20 x 100 meter Hann smoothing window
	%testDir%\mergeBathy.exe ..\output_files\T10C04_CPP_DUCK_10x10g_20x100s 10 hann ..\..\..\Test_Set_10_OSP_Paper\Active_Testing_Site\input_file_lists\input_file_list_duckExample.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 20 100 -modelflag -nonegdepth > ..\command_line_execution\T10C04_DUCK_10x10g_20x100s_output.txt
	echo ...done.
	echo.
	echo TEST CASE 5: DBDBV 926 x 926 meter grid with 1234.67 x 1234.67 meter Hann smoothing window and pre-splined with 617.33 x 617.33 meter zgrid MB-System modelflag, NOnonegdepth
	::j mgrid 926 smooth 1234.67 mbz 617.33
	%testDir%\mergeBathy.exe ..\output_files\T10C05_CPP_DBDBV_0.5_NoOverlapMBZ 926 hann ..\..\..\Test_Set_10_OSP_Paper\Active_Testing_Site\input_file_lists\DBDBV_test_input_file_list_NoOverlap_e.txt -129 49.5 0 -1 -nmsei -msri -multiThread 8 -mse 1 -modelflag -msmooth 1234.67 1234.67 -ZGrid 617.33 617.33 ..\output_files\T10C05_CPP_DBDBV_0.5_NoOverlap_MBZ_xyde 0.1 -2 > ..\command_line_execution\T10C05_DBDBV_MBZ_output.txt
	%testDir%\mergeBathy.exe ..\output_files\T10C05_CPP_DBDBV_0.5_NoOverlapMBZK 926 hann ..\..\..\Test_Set_10_OSP_Paper\Active_Testing_Site\input_file_lists\DBDBV_test_input_file_list_NoOverlap_e.txt -129 49.5 0 -1 -nmsei -msri -multiThread 8 -mse 1 -modelflag -msmooth 1234.67 1234.67 -ZGrid 617.33 617.33 ..\output_files\T10C05_CPP_DBDBV_0.5_NoOverlap_MBZ_xyde 0.1 -2 -kriging > ..\command_line_execution\T10C05_DBDBV_MBZK_output.txt
	echo ...done.
	echo.

	if exist ..\output_files\*.txt move /Y ..\output_files\*.txt ..\output_files\%mPLATFORM%\%mCONFIGURATION%
	if exist ..\output_files\*.bag move /Y ..\output_files\*.bag ..\output_files\%mPLATFORM%\%mCONFIGURATION%
	if exist ..\output_files\*.xml move /Y ..\output_files\*.xml ..\output_files\%mPLATFORM%\%mCONFIGURATION%
	if exist ..\output_files\*.asc move /Y ..\output_files\*.asc ..\output_files\%mPLATFORM%\%mCONFIGURATION%
	if exist ..\output_files\*.prj move /Y ..\output_files\*.prj ..\output_files\%mPLATFORM%\%mCONFIGURATION%
	if exist ..\command_line_execution\*.txt move /Y ..\command_line_execution\*.txt ..\command_line_execution\%mPLATFORM%\%mCONFIGURATION%
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
	cls
	echo.
	echo runInterpTests.bat done.
	goto:endRun

:endRun
	pause
	EXIT /B