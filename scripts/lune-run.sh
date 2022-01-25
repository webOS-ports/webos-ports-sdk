#!/bin/bash

# Package the given folder as an app, using palm-package
# Push the app to the device, using adb
# Install the app, using luna-send commands over adb
# Run the app on the device, using luna-send commands over adb
# Watch the logs, using shell commands over adb

APPFOLDER=$1

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo lune-run: no devices found via adb
    exit
fi

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
echo
lune-log $ipkname