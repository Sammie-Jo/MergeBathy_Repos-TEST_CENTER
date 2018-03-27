README-examples.txt

There are four folders in this directory
	bat_files
	bash_files
	command_line_execution
	input_file_lists
	output_files

In order to run the example test sets the directory structure of these three folders and its parent folder sub-directories containing DATA_CENTER, TEST_CENTER, and mergeBathy_CPP must not change.

The "bat_files" (WINDOWS) directory contains all of the test scripts and command arguments needed to run the test data in the "DATA_CENTER" directory.  To run the test scripts keep the "mergeBathy" executable in its generated folder, keep the mergeBathy_CPP directory unchanged within the same parent directory as TEST_CENTER, and run the selected bash file.  

The "bash_files" (UNIX) directory contains all of the test scripts and command arguments needed to run the test data in the "DATA_CENTER" directory.  To run the test scripts keep the "mergeBathy" executable in its generated folder, keep the mergeBathy_CPP directory unchanged within the same parent directory as TEST_CENTER, and run the selected bash file.  

The "command_line_execution" contains the command line output generated for each test run performed in the "runInterpTests.bat" file.  The test case names match the command line output file names.  

The "input_file_lists" directory contains the test input data used to test "mergeBathy".

The sub-folder "output_files" contains example output from select test cases.  The output file names are unique to the individual data run performed in by the executed bat/bash file.  
