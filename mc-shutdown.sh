#!/bin/bash
function say () {
    minecraftd command say $1
}

# Warn per minute
for time in $(seq 4 -1 1)
do
    say "==============================="
    say "SERVER GOING DOWN IN $time MINUTES"
    say "==============================="
    sleep 60
done

# Warn per second
for time in $(seq 5 -1 1)
do
    say "SERVER RESTART IN T-$time"
    sleep 1
done

say "SERVER GOING DOWN FOR MAINTANECE, WILL BE BACK SOON-ISH"
sleep 5 # Give them time to see this

minecraftd command stop
