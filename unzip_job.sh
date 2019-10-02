#!/bin/bash

BASE_DIR=/srv/ftp
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
    if [ ${#PIDS[@]} -ge $JOBS ]
    then
        top=${PIDS[0]}
	wait $top
	PIDS=(${PIDS[@]/$top})
    fi
}

function unzip_task() {
    zip_file=$1
    dest=$2
    wait_queue
    echo "$zip_file > $dest"
    echo
    unzip $zip_file -d $dest &
    PIDS+=($!)
}

# Keep from splitting whitespace
IFS=$'\n'

# Allow custom search dir
[ $# -eq 0 ] || BASE_DIR=$1

for file in $(find $BASE_DIR -name "*.zip")
do
    out_dir=${file%.zip}
    # if the file is not already unzipped, unzip it
    [ -f $out_dir ] || unzip_task $file $out_dir
done

unset IFS
