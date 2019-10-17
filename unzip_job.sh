#!/bin/bash

BASE_DIR=/bdisk/ftp/shows
GRAVEYARD=/bdisk/zip_graveyard
QUARANTINE=/var/quarantine
LOG=/var/log/zip.log
PIDS=()
JOBS=4

trap ctrl_c INT

# On ctrl-c kill all active unzipping processes and exit
function ctrl_c() {
    echo "INT signal recieved, stopping"
    for pid in $PIDS
    do
        kill $pid
    done
    exit
}

function wait_queue() {
    [ ${#PIDS[@]} -lt $JOBS ] && return

    top=${PIDS[0]}
    wait $top
    PIDS=(${PIDS[@]/$top})
}

function security_check() {
    # I use a custom tool on my server that checks for zip bombs
    # If it's not installed just skip this function
    which bloodhound &> /dev/null || return 0

    bloodhound $1

    if [ $? -ne 0 ]
    then
        echo "Possible zip bomb detected! $zip_file"
        mv $zip_file $QUARANTINE
        return 1
    fi

}

# Unzip the file. Runs $JOBS zip taks at a time. If all the tasks
# are running then this process waits for one to be done.
function unzip_task() {
    zip_file=$1
    dest=$2

    wait_queue
    security_check
    echo "$zip_file > $dest"
    echo
    unzip $zip_file -d $dest &
    PIDS+=($!)
}

function fd_find() {
   # Use fd if it's installed, use find if not
   if which fd > /dev/null 2>&1
   then
       fd .*zip -j 4 $BASE_DIR
   else
       find $BASE_DIR -name '*.zip'
   fi
}

# Keep from splitting whitespace
IFS=$'\n'

# If arguments are provided use them as the search path
[ $# -eq 0 ] || BASE_DIR=$1

#for file in $(find $BASE_DIR -name "*.zip")
for file in $(fd_find)
do
    out_dir=${file%.zip}
    [ -e $out_dir ] || unzip_task $file $out_dir
done

unset IFS
