#!/bin/bash

# Start the SECONDS timer
SECONDS=0
#capturing the start time
START=$(date +"%T") 											

# Handle program abort 
abort() {
 echo "The process aborted by sending halt signal." >> $log
 #open the log file
 if which xdg-open &> /dev/null; then
     # Linux environment
     xdg-open $log
 else
     # OS X environment
     open $log
 fi
 exit 0
}

# Initialize
init() {
 # Extracted files counter
 extractedFiles=0
 # Normal files counter
 normalFiles=0
 # Abort in case of error
 set -e
 if [ "$1" == "-c" ]; then
	# Set the log file name and type
	log="$2"
 else
 	# Use default log
	log=report.txt
 fi
 if [ "$1" != "-v" ]; then
 	# Verbose mode off -> redirect to /dev/null
	exec 1>/dev/null
 fi
 if [ "$1" == "-d" ]; then
 	# Change the directory to destination directory
	cd "$2"
 fi
}

# Handling archives and compressed files
handle_archives() {
 # Step in archive directory or create it
 [ -d archive ] || mkdir archive
 # If archive should be extracted, extract/uncompress it
 if [ "$1" == "-z" ]; then
	mkdir "archive/${2%.*}"
    unzip -d "archive/${2%.*}" "./$2"
    echo "\"$2\" extracted in $PWD/archive/${2%.*}" >> $log	
    extractedFiles=$(expr $extractedFiles + 1)
 else
 	# If extract flag is not provided, just move the thing
    mv -- "$2" "archive/"
    echo "\"$2\" moved in $PWD/archive/" >> $log
    normalFiles=$(expr $normalFiles + 1)
 fi
}

# Handle normal files
handle_files() {
 # Why is this control here?!
 if [ "$1" != "-z" ]; then
	mkdir -p "${2##*.}"
    mv -- "$2" "${2##*.}/"
    echo "\"$2\" moved to $PWD/${2##*.}" >> $log
 	normalFiles=$(expr $normalFiles + 1)
 fi
}

# Finish things up
wrapup() {
 echo "Done in $SECONDS seconds!"
 # Capture the ending time
 END=$(date +"%T")
 echo "Number of files moved: $normalFiles" >> $log
 echo "Number of files extracted: $extractedFiles" >> $log
 echo "Start time: $START" >> $log
 echo "End time: $END" >> $log
 #open the log file
 if which xdg-open &> /dev/null; then
     # Linux environment
     xdg-open $log
 else
     # OS X environment
     open $log
 fi
}

# In case of sigint(signal 2 aka ctrl+c) call abort function
trap abort 2
# Init the program with 
init "$1" "$2"
echo "trigger took place in $PWD"
# Loop through files in current working directory
for i in *; do
	echo "processing \"$i\" ..."
	case $i in
		*.zip)
		  # Handle zip files
		  handle_archives "$1" "$i";;
		*.*)
		  # Just in case of anything else BUT WITH extension	
		  handle_files "$1" "$i";;
		*)
		  # In case of files without extensions, move them to temp
		  tmp=$(TMPDIR=. mktemp -d)
		  mv -- "$i" "$tmp/"
		  mv -- "$tmp" "$i"
		  normalFiles=$(expr $normalFiles + 1);;
	esac
done
# Wrap things up
wrapup
