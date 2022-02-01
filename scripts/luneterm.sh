#!/bin/bash

# Lauch appropriate shell

DEVICE=1
ADDRESS=localhost
PORT=5522

if [ "$1" != "" ]; then
    ADDRESS=$1
    PORT=22
fi

if [ "$2" != "" ]; then
    PORT=$2
fi

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo "luneterm: no devices found via adb, trying to connect to emulator..."
    echo
    DEVICE=0
fi

if [ $DEVICE -eq 1 ]; then
    adb shell
else
    ssh root@$ADDRESS -p $PORT
fi

exit