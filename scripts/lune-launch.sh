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
ARG=$2

# List apps
if [ "$IPKNAME" = "-l" -o "$IPKNAME" = "--list" ]; then
    echo listing apps
    adb shell "/usr/bin/luna-send -n 1 -f luna://com.palm.applicationManager/listApps '{}'"
    exit
fi

# Close an app
if [ "$ARG" = "-c" -o "$ARG" = "--close" ]; then
    echo not implemented
    exit
    # TODO: need to list apps to find the ID of the process to kill
    #luna-send -n 1 -f luna://com.palm.applicationManager/close '{ "processId": "###" }'
    exit
fi

# Relaunch an app
#if [ "$ARG" = "-f" -o "$ARG" = "--relaunch" ]; then
#    echo closing $IPKNAME
#    #luna-send -n 1 -f luna://com.palm.applicationManager/close '{ "processId": "###" }'
#fi

# Launch the app
echo launching $IPKNAME
adb shell "/usr/bin/luna-send -n 1 -f luna://com.palm.applicationManager/launch '{ \"id\": \"$IPKNAME\" }'"