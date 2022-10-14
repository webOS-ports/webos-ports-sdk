#!/bin/bash

# Try to launch app with luna via adb
# Then follow logs

if [ "$1" = "" ]; then
    echo lune-launch: missing arguments
    echo Pass the appid of the previously installed app you want to run.
    echo eg: lune-run com.yourdomain.yourapp
    exit
fi
IPKNAME=$1
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
    echo "lune-launch: no devices found via adb, using ssh at $ADDRESS:$PORT"
    DEVICE=0
fi

# List apps
if [ "$1" = "-l" -o "$1" = "--list" ]; then
    # TODO: handle as named argument, not positional, because it interferes with other args
    echo listing apps
    command="/usr/bin/luna-send -n 1 -f luna://com.palm.applicationManager/listApps '{}'"
    remoteShellCmd $DEVICE, $command
    exit
fi

# Close an app
if [ "$2" = "-c" -o "$2" = "--close" ]; then
    echo not implemented
    exit
    # TODO: handle as named argument, not positional, because it interferes with other args
    # TODO: need to list apps to find the ID of the process to kill
    #luna-send -n 1 -f luna://com.palm.applicationManager/close '{ "processId": "###" }'
    exit
fi


# Relaunch an app
#TODO: related to above, but not currently needed
#if [ "$ARG" = "-f" -o "$ARG" = "--relaunch" ]; then
#    echo closing $IPKNAME
#    #luna-send -n 1 -f luna://com.palm.applicationManager/close '{ "processId": "###" }'
#fi

# Launch the app
echo launching $IPKNAME
command="/usr/bin/luna-send -n 1 -f luna://com.palm.applicationManager/launch '{ \"id\": \"$IPKNAME\" }'"
remoteShellCmd $DEVICE, $command