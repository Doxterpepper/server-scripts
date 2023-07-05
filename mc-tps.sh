#! /bin/bash

function debug() {
    minecraftd command debug $1
}

debug start
sleep 10
debug stop | grep "ticks per"
