#!/bin/bash
IPKNAME=$1

# Try to launch app with given name (appid)
# Then follow logs

# Launch the app
echo launching $IPKNAME
adb shell "/usr/bin/luna-send -n 1 -f luna://com.palm.applicationManager/launch '{ \"id\": \"$IPKNAME\" }'"
echo
# Tracing
echo following logs
adb shell "journalctl -f -l -u luna-webappmanager"
