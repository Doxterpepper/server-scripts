
function start () {
    minecraftd command debug start
}

function stop () {
    minecraftd command debug stop
}


while true
do
    date
    start
    sleep 10
    stop
    echo
done
