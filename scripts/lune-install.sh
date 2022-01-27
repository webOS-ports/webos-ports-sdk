#!/bin/bash

# Package the given folder as an app, using palm-package
# Push the app to the device, using adb
# Install the app, using luna-send commands over adb
# Run the app on the device, using luna-send commands over adb
# Watch the logs, using shell commands over adb

if [ "$1" = "" ]; then
    echo lune-install: missing arguments
    echo Pass the directory of the app code to install as the first -- and only -- argument.
    echo eg: lune-install ~/myapp
    exit
fi
IPK=$1
DEVICE=1

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo lune-install: no devices found via adb, assuming emulator
    DEVICE=0
fi

# Figure all the names we need
ipkfile=$(basename "$IPK")
ipkname="$(echo $ipkfile | cut -d'_' -f1)"

# If they asked to remove an app, do that instead of everything else
if [ "$2" = "-r" ]; then
    echo removing package $ipkname
    # new command?
    command="/usr/bin/luna-send -n 10 -f luna://com.webos.appInstallService/remove '{ \"id\": \"$ipkname\", \"subscribe\": true }'"
    if [ $DEVICE -eq 1 ]; then
        adb shell $command
    else
        # emulator currently still uses original command
        command="/usr/bin/luna-send -n 10 -f luna://com.palm.appinstaller/remove '{ \"packageName\": \"$ipkname\", \"subscribe\": true }'"
        ssh root@localhost -p 5522 $command
    fi
    exit
fi

# Tidy up
command="rm /tmp/*.ipk 2>null"
if [ $DEVICE -eq 1 ]; then
    adb shell $command
else
    ssh root@localhost -p 5522 $command
fi

# Push and install the app
echo pushing package $IPK
command="$IPK"
if [ $DEVICE -eq 1 ]; then
    adb push $command /tmp
else
    scp -P 5522 $command root@localhost:/tmp
fi
echo

echo re/installing $ipkname
# To install a System app:
#   adb shell "opkg install --force-reinstall --force-downgrade /tmp/$ipkfile && rm /tmp/*.ipk"
# new command, per Herrie
command="/usr/bin/luna-send -n 1 luna://com.webos.appInstallService/install  '{\"subscribe\":true, \"id\": \"$ipkname\", \"ipkUrl\": \"/tmp/$ipkfile\"}'"
if [ $DEVICE -eq 1 ]; then
    adb shell $command
else
    # emulator currently still uses original command
    command="/usr/bin/luna-send -n 6 luna://com.palm.appinstaller/installNoVerify '{\"subscribe\":true, \"target\": \"/tmp/$ipkfile\"}'"
    ssh root@localhost -p 5522 $command
fi
sleep 1