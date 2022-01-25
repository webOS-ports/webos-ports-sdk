#!/bin/bash

# Package the given folder as an app, using palm-package
# Push the app to the device, using adb
# Install the app, using luna-send commands over adb
# Run the app on the device, using luna-send commands over adb
# Watch the logs, using shell commands over adb

APPFOLDER=$1
# Get SDK to package app
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

echo
# Figure all the names we need and tidy up
ipkfile=$(basename "$ipk")
ipkname="$(echo $ipkfile | cut -d'_' -f1)"
adb shell "rm /tmp/*.ipk 2>null"

# Push and install the app
echo pushing package $ipk
adb push $ipk /tmp
echo
echo installing $ipkname
# To install a System app:
#   adb shell "opkg install --force-reinstall --force-downgrade /tmp/$ipkfile && rm /tmp/*.ipk"
adb shell "/usr/bin/luna-send -n 6 luna://com.palm.appinstaller/installNoVerify '{\"subscribe\":true, \"target\": \"/tmp/$ipkfile\"}'"
sleep 1

echo
lune-log $ipkname