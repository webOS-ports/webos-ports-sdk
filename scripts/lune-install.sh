#!/bin/bash

# Package the given folder as an app, using palm-package
# Push the app to the device, using adb
# Install the app, using luna-send commands over adb
# Run the app on the device, using luna-send commands over adb
# Watch the logs, using shell commands over adb

IPK=$1

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo lune-install: no devices found via adb
    exit
fi

# Figure all the names we need and tidy up
ipkfile=$(basename "$IPK")
ipkname="$(echo $ipkfile | cut -d'_' -f1)"
adb shell "rm /tmp/*.ipk 2>null"

# Push and install the app
echo pushing package $IPK
adb push $IPK /tmp
echo
echo installing $ipkname
# To install a System app:
#   adb shell "opkg install --force-reinstall --force-downgrade /tmp/$ipkfile && rm /tmp/*.ipk"
adb shell "/usr/bin/luna-send -n 6 luna://com.palm.appinstaller/installNoVerify '{\"subscribe\":true, \"target\": \"/tmp/$ipkfile\"}'"
sleep 1