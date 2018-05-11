#!/bin/bash

# Copyright (c) 2013 Hans Kokx
# Copyright (c) 2018 Herman van Hazendonk <github.com@herrie.org>
#
# Licensed under the GNU General Public License, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.gnu.org/copyleft/gpl.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

logo() {
  clear
  echo "
                     __   ____  _____
         _    _____ / /  / __ \/ __/    
        | |/|/ / -_) _ \/ /_/ /\ \      
        |__,__/\__/_.__/\____/___/            webOS-ports installer
           ___           __                   
          / _ \___  ____/ /____         
         / ___/ _ \/ __/ __(_-<                            by HaDAk
        /_/   \___/_/  \__/___/         
"
}

displayhelp() {
  logo
  cat << EOF
Usage: $0 <options>
  --help (-h): display this handy help message
  --staging (-s): use the staging [EXPERIMENTAL] feed
  --verbose (-v): display relevant status messages
  --skipkernel (-k): do not flash a new kernel
EOF
}

tagline="[#] webOS-ports LuneOS installer by HaDAk"
getdev=`adb shell getprop ro.product.device`
build=""
verbose="false"
skipkernel="false"

parseopts()
{
    until [ $# -eq 0 ]
    do
        if [[ $1 == "--help" || $1 == "-h" ]]; then
          displayhelp
          exit 1
        elif [[ $1 == "--staging" || $1 == "-s" ]]; then
          build="-staging"
        elif [[ $1 == "--verbose" || $1 == "-v" ]]; then
          verbose="true"
        elif [[ $1 == "--skipkernel" || $1 == "-k" ]]; then
          skipkernel="true"
        elif [[ $1 == "-svk" ]]; then
          build="-staging"
          verbose="true"
          skipkernel="true"
        elif [[ $1 == "-sv" || $1 == "-vs" ]]; then
          build="-staging"
          verbose="true"
        elif [[ $1 == "-sk" || $1 == "-ks" ]]; then
          build="-staging"
          skipkernel="true"
        fi
        shift 1
    done
    if [[ ! $build == "-staging" ]]; then
      displayhelp
      echo ""
      echo "[!] There are currently no stable builds. Please try the staging feed."
      exit 2
    fi
}
parseopts "$@"


spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

warning() {
echo '
WARNING:
This program may cause irreperable damage to your tablet.  If you are not
comfortable with alpha-quality software, and any issues that may arise from
trying to install and use alpha-quality software, please DO NOT use this
program.

This installer assumes that your device is accessable via adb, and your
bootloader is unlocked.  It also assumes that you currently have ClockworkMod
or TWRP installed. Other custom recoveries have not been tested, and are not guaranteed
to work with this installer.

'
read -p "Press [Enter] key to continue..."
clear
}

disclaimer() {
echo 'DISCLAIMER: This installer will attempt to guide you though installing ALPHA
quality software.  It has the capability of BRICKING your device. As such, you
acknowledge that you take full responsibility for using this software and
neither webOS-Ports nor Hans Kokx (aka "HaDAk") are responsible for the outcome
of using this software.

THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.
EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE PROGRAM “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE
QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE
DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

For the full disclaimer, please visit http://www.gnu.org/copyleft/gpl.html'
read -p "Press [Enter] key to continue..."
clear

echo "[?] Do you wish to accept full liability of damages"
echo "[?] and install LuneOS on your device?"
read -p "[y/n]: "
if [ $REPLY != "y" ]; then
  echo "[!] Installation aborted by user. Goodbye."
  exit 1
fi
clear
}

testadb() {
    if hash adb 2>/dev/null; then
      :
    else
        echo "[!] adb not found in your path. Please install adb. Aborting."
        exit 2
    fi
}

connectedas=""
check="0"
device_not_found="List of devices attached"
adb_check_device=`adb devices 2>/dev/null | tail -2 | head -1 | cut -f 1 | sed 's/ *$//g'`

checkdevice() {
  fastboot_check_device=`fastboot devices 2>/dev/null | tail -2 | head -1 | cut -f 1 | sed 's/ *$//g'`
  check=`expr $check + 1`

  if [[ ${fastboot_check_device} == "" ]]; then
    if [[ ${adb_check_device} == ${device_not_found} ]]; then
      echo "[!] No device found."
      echo "[i] Please ensure your device is powered on and usb debugging is enabled."
      echo "[!] Aborting."
      exit 2
    else
      connectedas="adb"
      if [[ $check -le 1 && $verbose == "true" ]]; then
        echo "[i] Device found."
      fi
    fi
  else
    connectedas="fastboot"
      if [[ $check -le 1 && $verbose == "true" ]]; then
        echo "[i] Device found."
      else
        echo "[!] Device is still in fastboot. Please manually reboot now."
        adb wait-for-device
        echo "[i] Device found."
      fi
  fi
}

base="false"
kern="false"
connection="false"

checkconnection() {
  connection=`ping -q -c 1 build.webos-ports.org > /dev/null && echo ok || echo error`
  if [[ ${connection} != "ok" ]]; then
    connection="false"
  else
    connection="true"
  fi
}

checklocalfiles() {
  if [ -f webos-ports-package-grouper.zip ]; then
    read -p "[?] Base image found. Use local copy? [y/n] "
    if [ $REPLY != "y" ]; then
      base="true"
    fi
  else
    base="true"
  fi
  if [[ -f zImage-grouper.fastboot && $skipkernel == "false" ]]; then
    read -p "[?] Kernel image found. Use local copy? [y/n] "
    if [ $REPLY != "y" ]; then
      kern="true"
    fi
  else
    kern="true"
  fi
  download
}

download() {
  checkconnection

  BASEIMG="http://build.webos-ports.org/webos-ports$build/latest/images/grouper/webos-ports-package-grouper.zip"
  KERNEL="http://build.webos-ports.org/webos-ports$build/latest/images/grouper/zImage-grouper.fastboot"
  curlopt=""
  if [[ $base == "true" && $connection == "true" ]]; then
    if [[ $verbose == "true" ]]; then
      echo -n "[>] Fetching base image..."
      (curl -s $BASEIMG -o webos-ports-package-grouper.zip) &
      spinner $!
      echo ""
    else
      curl $BASEIMG -o webos-ports-package-grouper.zip
    fi
    base="false"
  elif [[ $base == "true" && $connection == "false" ]]; then
    echo "[!] Unable to connect to the webOS Ports server."
    exit 2
  else
    if [[ $verbose == "true" ]]; then
      echo "[i] Using local base image."
      base="false"
    fi
  fi


  if [[ $kern == "true" && $connection == "true" && $skipkernel == "false" ]]; then
    if [[ $verbose == "true" ]]; then
      echo -n "[>] Fetching kernel image..."
      (curl -s $KERNEL -o zImage-grouper.fastboot) &
      spinner $!
      echo ""
    else
      curl $KERNEL -o zImage-grouper.fastboot
    fi
    kern="false"
  elif [[ $kern == "true" && $connection == "false" && $skipkernel == "false" ]]; then
    echo "[!] Unable to connect to the webOS Ports server."
    exit 2
  else
    if [[ $verbose == "true" ]]; then
      echo "[i] Using local kernel image."
    fi
  fi

  if [[ $base == "false" && $kern == "false" ]]; then
    if [[ $verbose == "true" ]]; then
      echo "[i] Waiting 10 seconds for device to come up."
    fi
    sleep 10
  fi
}

getrecovery() {
  if [[ $connectedas == "adb" ]]; then
    if [[ $verbose == "true" ]]; then
      echo "[>] Booting recovery."
    fi
    adb reboot recovery 2>/dev/null
    sleep 20
  else
    if [[ $verbose == "true" ]]; then
      echo "[>] Device is in fastboot. Rebooting to recovery."
    fi
    fastboot reboot 2>/dev/null
    adb wait-for-device 2>/dev/null
    adb reboot recovery 2>/dev/null
    sleep 20
  fi
}

install() {
  if [[ $verbose == "true" ]]; then
    echo -n "[>] Copying base image. This will take a while."
    (adb push webos-ports-package-grouper.zip /cache/ 2>/dev/null) &
    spinner $!
    echo ""
  else
    adb push webos-ports-package-grouper.zip /cache/ 2>/dev/null
  fi

  if [[ $verbose == "true" ]]; then
    echo -n "[>] Installing base image..."
    (adb shell recovery --update_package=/cache/webos-ports-package-grouper.zip &2>/dev/null) &
    spinner $!
    echo ""
  else
    adb shell recovery --update_package=/cache/webos-ports-package-grouper.zip &2>/dev/null
  fi

  echo "[!] Please follow device's on-screen prompts to continue."
  sleep 15
  read -p "[!] Once the install is complete, press [Enter] to continue."

  if [[ $skipkernel == "true" ]]; then
    echo "[*] LuneOS has been successfully installed."
    elif [[ $skipkernel == "false" ]]; then
    adb reboot bootloader 2>/dev/null
    sleep 3
    
    if [[ $verbose == "true" ]]; then
      echo -n "[>] Flashing kernel image..."
      (fastboot flash boot zImage-grouper.fastboot 2>/dev/null) &
      spinner $!
      fastboot reboot 2>/dev/null
      echo ""
      echo "[*] LuneOS has been successfully installed."
    else
      fastboot flash boot zImage-grouper.fastboot 2>/dev/null
      echo "[*] LuneOS has been successfully installed."
      fastboot reboot 2>/dev/null
    fi
    
    if [[ $verbose == "true" ]]; then
      echo "[i] Kernel flashed successfully."
    fi
  fi

  adb reboot 2>/dev/null
} 

cleanup() {
  read -p "[?] Do you wish to delete the temporary files? [y/n] "
  if [ $REPLY == "y" ]; then
    rm -f webos-ports-package-grouper.zip
    rm -f zImage-grouper.fastboot
  fi
}

finish() {
  echo "[*] All done! Enjoy LuneOS :) -HaDAk"
}

main() {
   logo
   warning
   disclaimer
   testadb
   checkdevice
   getrecovery
   checklocalfiles
   install
   cleanup
   finish
  :
}

main