#!/bin/bash

# This installer for macOS attempts to detect the webOS SDK, then augment
# it by adding scripts to provide similar commands for LuneOS. If those 
# scripts are already present, they'll be overwritten to allow for in-place
# upgrades or bug fixes.

#Check for sufficient privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run with Elevated Privileges"
  echo
  read -rsp $'Press any key to continue . . .\n' -n1 key
  exit
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PALM_SCRIPTS=/opt/PalmSDK/0.1/bin

#Check for ADB
if ! hash adb 2>/dev/null
then
    echo "adb was not found in PATH. Please install adb first."
    echo "Download from developer.android.com"
    echo
    read -rsp $'Press any key to continue . . .\n' -n1 key
    exit
fi

#Check for PalmSDK
if [ ! -d "$PALM_SCRIPTS" ]; then
  echo "Palm SDK not found. Please install the PalmSDK first."
  echo "Download from: sdk.webosarchive.org"
  echo
  read -rsp $'Press any key to continue . . .\n' -n1 key
  exit
fi

#Patch in new stuff
echo Patching Palm webOS SDK to add LuneOS support . . .
echo
yes | cp $DIR/scripts/* $PALM_SCRIPTS
chmod +x $PALM_SCRIPTS/*.sh
for file in $PALM_SCRIPTS/*.sh; do
    ofname=$(basename "$file")
    nfname=$(basename "$file" .sh)
    echo "Adding $nfname"
    mv -f $PALM_SCRIPTS/$ofname $PALM_SCRIPTS/$nfname
done
echo

echo Done! Install Completed