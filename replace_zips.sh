FTP_DIR=/bdisk/ftp
GRAVEYARD=/bdisk/zip_graveyard
JOBS=4
PIDS=()

trap ctrl_c INT

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

function error() {
    echo $1
    exit 1
}



#[ $# -lt 1 ] && error "Please specify a file"

IFS=$'\n'
for file in $(ls $GRAVEYARD)
do
    file_path="$GRAVEYARD/$file"
    echo $file_path
    extension="${file##*.}"
    [ "$extension" = "zip" ] || error "file must be a zip file"
    zip_dir=${file%.zip}
    move_dir=$(dirname "$(find $FTP_DIR -name "$zip_dir")")
    move_dir=$(echo $move_dir | sed 's/ /\\ /g')
    wait_queue
    echo "$file > $move_dir"
    echo
    cp $file_path "$move_dir" &
    IDS+=($!)
done
unset IFS
