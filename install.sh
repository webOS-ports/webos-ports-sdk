#!/bin/bash

# This installer attempts to detect the webOS SDK, then augment it by 
# adding scripts to provide similar commands for LuneOS. If those scripts
# are already present, they'll be overwritten to allow for in-place
# upgrades or bug fixes.

#Check for sufficient privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run with Elevated Privileges"
  echo
  read -rsp $'Press any key to continue . . .\n' -n1 key
  exit
fi
PALM_SCRIPTS=/opt/PalmSDK/0.1/bin
#Check for PalmSDK
if [ ! -d "$PALM_SCRIPTS" ]; then
  echo "Palm SDK not found. Please install the PalmSDK first."
  echo "Download from: sdk.webosarchive.com"
  echo
  read -rsp $'Press any key to continue . . .\n' -n1 key
  exit
fi
echo Patching Palm webOS SDK to add LuneOS support . . .
echo
yes | cp ./scripts/* $PALM_SCRIPTS
chmod +x $PALM_SCRIPTS/*.sh
for file in $PALM_SCRIPTS/*.sh; do
    ofname=$(basename "$file")
    nfname=$(basename "$file" .sh)
    #echo "$nfname"
    echo "ln -s /usr/local/bin/$nfname $PALM_SCRIPTS/$ofname"
    ln -s $PALM_SCRIPTS/$ofname /usr/local/bin/$nfname

done

echo Done! Install Completed