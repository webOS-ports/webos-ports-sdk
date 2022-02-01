#!/bin/bash

# Try to launch app with given name (appid)
# To log without launching an app, pass . for the appid TODO: This is a hack
# Then follow logs

IPKNAME=.
DEVICE=1
ADDRESS=localhost
PORT=5522

# Define function to run commands on device
function remoteShellCmd() {
    if [ $DEVICE -eq 1 ]; then
        adb shell $command
    else
        ssh root@$ADDRESS -p $PORT $command
    fi
}

if [ "$2" != "" ]; then
    ADDRESS=$2
    PORT=22
fi

if [ "$3" != "" ]; then
    PORT=$3
fi

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo lune-log: no devices found via adb, assuming emulator at $ADDRESS:$PORT
    DEVICE=0
fi

# Launch the app
if [ "$IPKNAME" != "." ]; then
    lune-launch $IPKNAME $2 $3
    echo
fi

# Tracing
echo following logs
command="journalctl -f -l -u luna-webappmanager"
remoteShellCmd $DEVICE $command
