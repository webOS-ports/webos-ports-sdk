#!/bin/bash

# Package the given folder as an app, using palm-package
# Push the app to the device, using adb
# Install the app, using luna-send commands over adb
# Run the app on the device, using luna-send commands over adb
# Watch the logs, using shell commands over adb

if [ "$1" = "" ]; then
    echo lune-run: missing arguments
    echo Pass the directory of the app code to run as the first -- and only -- argument.
    echo eg: lune-run ~/myapp
    exit
fi
APPFOLDER=$1
DEVICE=1

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo lune-run: no devices found via adb, assuming emulator
    DEVICE=0
fi

# Define function to run commands on device
function remoteShellCmd() {
    if [ $DEVICE -eq 1 ]; then
        adb shell $command
    else
        ssh root@localhost -p 5522 $command
    fi
}

# Ask SDK to package app
rm /tmp/*.ipk 2>null
palm-package $APPFOLDER -o /tmp

# Find what was just made
unset -v ipk
for file in "/tmp"/*.ipk; do
    [[ $file -nt $ipk ]] && ipk=$file
done
if [ -z "${ipk:-}" ]; then 
    echo "lune-run: cannot continue, palm-package did not produce a deployable ipk"
    exit
fi

# Install IPK that was just made
echo
lune-install $ipk

# Run the App and follow logs
ipkfile=$(basename "$ipk")
ipkname="$(echo $ipkfile | cut -d'_' -f1)"
echo launching $ipkname
command="/usr/bin/luna-send -n 1 -f luna://com.palm.applicationManager/launch '{ \"id\": \"$ipkname\" }'" 
remoteShellCmd $DEVICE, $command
echo
#lune-log $ipkname