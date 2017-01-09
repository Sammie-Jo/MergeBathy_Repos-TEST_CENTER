#!/bin/bash
##
# verify.sh
# Created by Samantha Zambo
# Aug 01, 2014
# 
# This bash script will verify output results by comparing with previously generated output files.
# This script will run the following tests.
#
# Requirements:
# 	Either Leave the directory unchanged 
# 	or modify all paths here and in respective files.
#
# To Run:
# 	1) Open terminal
# 	2) Change directory to folder containing verify.sh
# 	3) Type "sh ./verify.sh"
# 	4) if permission is denied type "chmod +rxw verify.sh"
#
##
shopt -s expand_aliases
# Must set this option, else script will not expand aliases.

alias cls='printf "\033c"'
echo $(cls)

bitModeID=3
configModeID=3
oldConfigModeID=0
read -p "Select (1) 32bit (2) 64bit (3) both : "  arg1
read -p "Select (1) Debug (2) Release (3) both : " arg2
if [ $arg1 ] ;then bitModeID=$arg1 ;fi
if [ $arg2 ] ;then configModeID=$arg2 ;fi

if [ -e "./verification_results.txt" ] ;then 
	chmod +rxw ./verification_results.txt
	rm ./verification_results.txt
fi

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

	if [[ ! -d ../output_files/$bitFolder/$configFolder ]] ;then
		echo "Verification Failed: No output files were generated!"
		echo "../output_files/$bitFolder/$configFolder Does not exist or is empty."
	fi
	if [[ ! -d ../output_files_unix/$bitFolder/$configFolder ]] ;then
		echo "Verification Failed: Original Window output files are needed to verify!"
		echo "../output_files_unix/$bitFolder/$configFolder Does not exist or is empty."
	fi

	diff -s -r -w ../output_files/$bitFolder/$configFolder ../output_files_unix/$bitFolder/$configFolder >> verification_results.txt

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

	#echo $(cls)
	echo
	echo "verify.sh done."
	break
done

wait

