#!/bin/bash
##
# runInterpTests.bat
# Created by Samantha J. Zambo
# Sept 27, 2016
# 
# This bash script will test the mergeBathy C++ version on Windows systems.
# This script will run 4 tests to generate OSP figures.
# (1) 50 x 50 meter grid with 50 x 50 meter Hann smoothing window
# (2) 10 x 10 meter grid with 10 x 10 meter Hann smoothing window
# (3) 10 x 10 meter grid with 20 x 20 meter Hann smoothing window
# (4) 10 x 10 meter grid with 20 x 100 meter Hann smoothing window
# (5) 10 x 10 meter grid with 20 x 100 meter Hann smoothing window with 10 x 10 GMT SIT pre-splined
# (6) 926 x 926 meter grid with 1234.67 x 1234.67 meter Hann smoothing window and pre-splined #with 617.33 x 617.33 MB-system zgrid
# (7) 926 x 926 meter grid with 1234.67 x 1234.67 meter Hann smoothing window and pre-splined #with 617.33 x 617.33 MB-system zgrid with kriging
#
# Requirements:
# 	Either Leave the directory unchanged 
# 	or modify all paths here and in respective files.
#
# Requirements:
# 	Either Leave the directory unchanged 
# 	or modify all paths here and in respective files.
#
# To Run:
# 	1) Open terminal
# 	2) Change directory to folder containing runValidationData.sh
# 	3) Type "sh ./runValidationData.sh"
# 	4) if permission is denied type "chmod +rxw runValidationData.sh"
#
##

#ulimit -c unlimited #uncomment to debug
shopt -s expand_aliases
# Must set this option, else script will not expand aliases.

alias cls='printf "\033c"'
echo $(cls)
echo ""
echo "***********************************************"
echo "* runInterpTests.sh"
echo "***********************************************"
echo ""
echo ""
#=====================================================================
# Find platform and configuration to test
mPLATFORM=x86
#mPLATFORM=x64
#mCONFIGURATION=Debug
mCONFIGURATION=Release

bitModeID=3
configModeID=3
oldConfigModeID=0
read -p "Select (1) 32bit (2) 64bit (3) both : "  arg1
read -p "Select (1) Debug (2) Release (3) both : " arg2
if [ $arg1 ] ;then bitModeID=$arg1 ;fi
if [ $arg2 ] ;then configModeID=$arg2 ;fi

while true; do
	if [ $configModeID -eq 3 ] ;then configFolder=Debug
	elif [ $configModeID -eq 1 ] ;then configFolder=Debug
	elif [ $configModeID -eq 2 ] ;then configFolder=Release
	else echo "Invalid configuration selection. Exit." ;break
	fi

	if [ $bitModeID -eq 3 ] ;then bitFolder=x86
	elif [ $bitModeID -eq 1 ] ;then bitFolder=x86
	elif [ $bitModeID -eq 2 ] ;then bitFolder=x64
	else echo "Invalid bit selection. Exit." ;break
	fi
	mPLATFORM=$bitFolder
	mCONFIGURATION=$configFolder	
	#if [ $# != 0 ] ;then
	#mPLATFORM=$1
	#mCONFIGURATION=$2
	#fi

	testDir=../../../.././mergeBathy_CPP/$mPLATFORM/$mCONFIGURATION
	echo TestingDir = 
	echo $testDir
	echo

	if [[ ! -d ../output_files/$mPLATFORM/$mCONFIGURATION ]] ;then mkdir -p "../output_files/$mPLATFORM/$mCONFIGURATION" ;fi
	if [[ ! -d ../command_line_execution/$mPLATFORM/$mCONFIGURATION ]] ;then mkdir -p "../command_line_execution/$mPLATFORM/$mCONFIGURATION" ;fi

	for f in `ls ../output_files/*.txt 2>/dev/null` ;do rm -f "$f" ;done
	for f in `ls ../output_files/*.bag 2>/dev/null` ;do rm -f "$f" ;done
	for f in `ls ../output_files/*.xml 2>/dev/null` ;do rm -f "$f" ;done
	for f in `ls ../output_files/*.asc 2>/dev/null` ;do rm -f "$f" ;done
	for f in `ls ../output_files/*.prj 2>/dev/null` ;do rm -f "$f" ;done
	for f in `ls ../command_line_execution/*.txt 2>/dev/null` ;do rm -f "$f" ;done
	#=====================================================================

	#Links shared libraries to applications
	export LD_LIBRARY_PATH=.:/usr/local/lib:../../../.././mergeBathy_CPP/extlibs/libs_unix/bag/$mPLATFORM/$mCONFIGURATION/lib:../../../.././mergeBathy_CPP/extlibs/libs_unix/libxml2/$mPLATFORM/$mCONFIGURATION/lib:../../../.././mergeBathy_CPP/extlibs/libs_unix/hdf5/$mPLATFORM/$mCONFIGURATION/lib:../../../.././mergeBathy_CPP/extlibs/libs_unix/beecrypt/$mPLATFORM/$mCONFIGURATION/lib
	export BAG_HOME=../../../.././mergeBathy_CPP/configdata
	echo   LD_LIBRARY_PATH = ;echo $LD_LIBRARY_PATH ;echo
	echo   BAG_HOME = 	 ;echo $BAG_HOME	;echo

	#Displays application's dynamically linked libraries
	#ldd $testDir/mergeBathy
	#Find libraries with libraryName
	#cd /
	#sudo find ./ | grep libraryName.so
	#=====================================================================
	#This is an example input file for demonstrating the capabilites of mergeBathy
	#! 36.177602 -75.749690 18.20 DuckNC mgrid 50 msmooth 50 nooffset plotpts modelflag nonegdepth

	echo "TEST CASE 1: Duck, NC 50 x 50 meter grid with 50 x 50 meter Hann smoothing window..."
	$testDir/mergeBathy ../output_files/T10C01_CPP_DUCK_50x50g_50x50s_e_meters 50 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/input_file_list_duckExample_e_meters.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 50 50 -modelflag -nonegdepth -inputInMeters > ../command_line_execution/T10C01_DUCK_50x50g_50x50s_e_meters_output.txt
	echo "done." 
	echo ""

	echo "TEST CASE 2: Duck, NC 10 x 10 meter grid with 10 x 10 meter Hann smoothing window..."
	$testDir/mergeBathy ../output_files/T10C02_CPP_DUCK_10x10g_10x10s_e_meters 10 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/input_file_list_duckExample_e_meters.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 10 10 -modelflag -nonegdepth -inputInMeters > ../command_line_execution/T10C02_DUCK_10x10g_10x10s_e_meters_output.txt
	echo "done." 
	echo ""

	echo "TEST CASE 3: Duck, NC 10 x 10 meter grid with 20 x 20 meter Hann smoothing window..."
	$testDir/mergeBathy ../output_files/T10C03_CPP_DUCK_10x10g_20x20s_e_meters 10 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/input_file_list_duckExample_e_meters.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 20 20 -modelflag -nonegdepth -inputInMeters > ../command_line_execution/T10C03_DUCK_10x10g_20x20s_e_meters_output.txt
	echo "done." 
	echo ""

	echo "TEST CASE 4: Duck, NC 10 x 10 meter grid with 20 x 100 meter Hann smoothing window..."
	$testDir/mergeBathy ../output_files/T10C04_CPP_DUCK_10x10g_20x100s_e_meters 10 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/input_file_list_duckExample_e_meters.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 20 100 -modelflag -nonegdepth -inputInMeters > ../command_line_execution/T10C04_DUCK_10x10g_20x100s_e_meters_output.txt
	echo "done." 
	echo ""

	#Will break for x86 too large
	echo "TEST CASE 5: Duck, NC 10 x 10 meter grid with 20 x 100 meter Hann smoothing window and 10 x 10 meter pre-splining SIT ..."
	$testDir/mergeBathy ../output_files/T10C05_CPP_DUCK_10x10g_20x100s_10x10GMT_e_meters 10 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/input_file_list_duckExample_e_meters.txt -75.749690 36.177602 18.20 -1 -nmsei -msri -multiThread 8 -mse 1 -msmooth 20 100 -modelflag -nonegdepth -GMTSurface 10 10 ../output_files/T10C05_CPP_DUCK_10x10g_20x100s_10x10GMT_e_meters_xyze 0.1 1.96 2 -2 -inputInMeters > ../command_line_execution/T10C05_DUCK_10x10g_20x100s_10x10GMT_e_meters_output.txt
	echo "done." 
	echo ""
	
	#Will break for x86 too large
	echo "TEST CASE 6: DBDBV 926 x 926 meter grid with 1234.67 x 1234.67 meter Hann smoothing window and pre-splined with 617.33 x 617.33 meter zgrid MB-System modelflag, NOnonegdepth..."
	#j mgrid 926 smooth 1234.67 mbz 617.33
	$testDir/mergeBathy ../output_files/T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ_e_meters 926 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/DBDBV_test_input_file_list_NoOverlap_e_meters.txt -129 49.5 0 -1 -nmsei -msri -multiThread 8 -mse 1 -modelflag -msmooth 1234.67 1234.67 -ZGrid 617.33 617.33 ../output_files/T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ_e_meters_xyde 0.1 -2 -inputInMeters > ../command_line_execution/T10C06_DBDBV_MBZ_e_meters_output.txt
	echo "done." 
	echo ""
	
	#Will break for x86 too large
	echo "TEST CASE 7: DBDBV 926 x 926 meter grid with 1234.67 x 1234.67 meter Hann smoothing window and pre-splined with 617.33 x 617.33 meter zgrid MB-System modelflag, NOnonegdepth with kriging..."
	#j mgrid 926 smooth 1234.67 mbz 617.33
	$testDir/mergeBathy ../output_files/T10C07_CPP_DBDBV_0.5_NoOverlap_MBZK_e_meters 926 hann ../../../Test_Set_10_OSP_Paper/Active_Testing_Site/input_file_lists/DBDBV_test_input_file_list_NoOverlap_e_meters.txt -129 49.5 0 -1 -nmsei -msri -multiThread 8 -mse 1 -modelflag -msmooth 1234.67 1234.67 -ZGrid 617.33 617.33 ../output_files/T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ_e_meters_xyde 0.1 -2 -kriging -inputInMeters > ../command_line_execution/T10C07_DBDBV_MBZK_e_meters_output.txt
	echo "done." 
	echo ""

	echo "Validation Completed."
	echo ""

	for f in `ls ../output_files/*.txt 2>/dev/null` ;do mv -f "$f" ../output_files/$mPLATFORM/$mCONFIGURATION ;done
	for f in `ls ../output_files/*.bag 2>/dev/null` ;do mv -f "$f" ../output_files/$mPLATFORM/$mCONFIGURATION ;done
	for f in `ls ../output_files/*.xml 2>/dev/null` ;do mv -f "$f" ../output_files/$mPLATFORM/$mCONFIGURATION ;done
	for f in `ls ../output_files/*.asc 2>/dev/null` ;do mv -f "$f" ../output_files/$mPLATFORM/$mCONFIGURATION ;done
	for f in `ls ../output_files/*.prj 2>/dev/null` ;do mv -f "$f" ../output_files/$mPLATFORM/$mCONFIGURATION ;done
	for f in `ls ../command_line_execution/*.txt 2>/dev/null` ;do mv -f "$f" ../command_line_execution/$mPLATFORM/$mCONFIGURATION ;done

	if [ $configModeID -eq 3 ] ;then
		configModeID=2
		oldConfigModeID=3
		continue
	fi
	if [ $bitModeID -eq 3 ] ;then
		configModeID=1
		bitModeID=2 
		if [ $oldConfigModeID -eq 3 ] ;then configModeID=3 ;fi
		continue
	fi

	echo $(cls)
	echo
	echo "runInterps_e_meters.sh done."
	break
done

wait


