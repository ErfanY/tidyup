#!/bin/bash
SECONDS=0														#start the SECONDS timer
START=$(date +"%T") 											#capturing the start time
abort()
{
 echo "The process aborted by sending halt signal." >> $log
 xdg-open $log													#open the log file
 exit 0															#exit the process
}
init()															#initialize function
{
 xtrctcntr=0													#counter of extracted files
 fcntr=0														#counter of normal files
 set -e															#abort in case of error
 if [ "$1" == "-c" ]; then										#if the -c option was used
	log="$2"													#set the log file name and type
 else
	log=report.txt												#default output of log
 fi
 if [ "$1" != "-v" ]; then										#if verbose mode was not triggered
	exec 1>/dev/null											#echo off everything
 fi
 if [ "$1" == "-d" ]; then										#if -d option was used
	cd "$2"														#change the directory to the new one
 fi
}
handle_archives()												#function for handling archive files
{
 [ -d archive ] || mkdir archive								#if archive folder is present cd in if not make it
 if [ "$1" == "-z" ]; then										#if -z option was being used
	mkdir "archive/${2%.*}"										#make a directory with the name of the arvhive file
    unzip -d "archive/${2%.*}" "./$2"							#unzip the archive file in the directory that was made in previous line
    echo "\"$2\" extracted in $PWD/archive/${2%.*}" >> $log		#report it to the log
    xtrctcntr=$(expr $xtrctcntr + 1)							#count the number of extracted archive(increment by one)
 else															#otherwise
    mv -- "$2" "archive/"										#move the file into the directory of archive
    echo "\"$2\" moved in $PWD/archive/" >> $log				#report it to the log
    fcntr=$(expr $fcntr + 1)									#count the number of moved files
 fi
}
handle_files()													#function to handle normal files
{
 if [ "$1" != "-z" ]; then										#if option -z was NOT being used
	mkdir -p "${2##*.}"											#make a parent directory with the name of the extension
    mv -- "$2" "${2##*.}/"										#move the file to that directory
    echo "\"$2\" moved to $PWD/${2##*.}" >> $log				#report it to the log
 	fcntr=$(expr $fcntr + 1)									#count the number of moved files
 fi
}
wrapup()														#function to finish things up
{
 echo "Done in $SECONDS seconds!"								#echo the number of seconds which the script executed 
 END=$(date +"%T")												#capture the ending time
 echo "Number of files moved: $fcntr" >> $log					#report the number of moved files to log
 echo "Number of files extracted: $xtrctcntr" >> $log			#report the number of extracted files to log
 echo "Start time: $START" >> $log								#echo the start time
 echo "End time: $END" >> $log									#echo the end time
 xdg-open $log													#open the log file
}
trap abort 2													#in case of sigint(signal 2 aka ctrl+c) call abort function
init "$1" "$2"													#calling init function and passing $1 and $2
echo "trigger took place in $PWD"								#echo where the script triggered
for i in *; do													#loop through files in the current directory
	echo "processing \"$i\" ..."								#echo on which file it is working now
	case $i in													#switch-case for the type of file
		*.zip)													#in case of zip
		  handle_archives "$1" "$i";;							#send it to the handle_archives along with first argument of script
		*.*)													#in case of anything else BUT WITH extension	
		  handle_files "$1" "$i";;								#send it to the handle_files to do normal proceedure
		*)														#in case of files without extensions
		  tmp=$(TMPDIR=. mktemp -d)								#create temp directory
		  mv -- "$i" "$tmp/"									#move the file to temp
		  mv -- "$tmp" "$i"
		  fcntr=$(expr $fcntr + 1);;							#count the number of normal moved files
	esac														#finish the case
done															#finish the loop
wrapup															#wrap things up
