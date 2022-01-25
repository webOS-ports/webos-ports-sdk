#!/bin/bash

# Copyright (c) 2013 Hans Kokx
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

testadb() {		## Verify ADB exists
    if hash adb 2>/dev/null; then
    	:
    else
        echo "[!] adb not found in your path. Please install adb. Aborting."
        exit 2
    fi
}

checkdevice() {	## Verify the device is connected and running webOS
	device_not_found="List of devices attached"
	check_device=`adb devices | tail -2 | head -1 | cut -f 1 | sed 's/ *$//g'`
 
	if [[ ${check_device} == ${device_not_found} ]]; then
		echo "[!] No device found. Aborting."
		exit 2
	else
		adb_test=$(adb shell ls -1 /usr/sbin|grep luna-next)
		if [[ -z "$adb_test" ]]; then
			echo "[!] Connected device is not running webOS. Aborting."
			exit 2
		fi
	fi
}

gatherdiag() {	## Generate diagnostics
	echo "[->] Gathering diagnostic files..."
	path=diag-`date +%d%m%Y%H%M%S`
	mkdir -p $path
	adb shell journalctl --no-pager > $path/journalctl
	adb shell opkg list > $path/opkg
	adb shell uname -a > $path/uname
	adb shell cat /proc/cmdline > $path/cmdline
	tar czf $path.tgz $path/*
	rm -rf $path
	echo "[->] Diagnostics saved to $path.tgz."
}

main() {		## Main subroutine
	echo "[#] webOS-ports diagnostics by HaDAk"
	testadb
	checkdevice
	gatherdiag
}

main