#!/bin/bash
IPKNAME=$1

# Try to launch app with given name (appid)
# Then follow logs

# Make sure there's a device to run on
devfound=false
adb get-state 1>/dev/null 2>&1 && devfound=true || devfound=false
if [ "$devfound" = "false" ]; then
    echo lune-log: no devices found via adb
    exit
fi

# Launch the app
lune-launch $IPKNAME
echo

# Tracing
echo following logs
adb shell "journalctl -f -l -u luna-webappmanager"
