# TidyUp

## Description
TidyUp is a file sorter script which sorts files based on the extension.

## Functionality
* This script creates a directory for each file extension and moves the files with that extension to this directory.
For example if there are files with .txt extension a **txt** directory is created and all files with *txt* extension are moved to this directory. Same rule applies for all extensions.

* All the archive files are moved to a directory named *archive*. Each archive is extracted in subdirectories in this directory i.e. foo.tgz is extracted in /archive/foo/

* The script generates a report after finishing the procedure. The directories created, file moved, archives extracted and the time stamps are printed in this report.

## Command line options
Use the below command line options for corresponding functionality:
* `-c` *name*:		Set the report name
* `-d` *dir*:		Execute script in the *dir* directory, if not passed, in current directory
* `-v` *verbose*:	Continue dispaying files move/unpack
* `-z` *archive*:	Unpack the archives, if not passed, only move them


