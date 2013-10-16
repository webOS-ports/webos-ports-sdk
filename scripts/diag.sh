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
        echo "[!] adb not found in your path. Please install adb."
        exit 1
    fi
}

gatherdiag() {	## Generate diagnostics
	echo "[->] Gathering diagnostic files..."
	mkdir -p ./diag`date +%d%m%Y%H%M%S`
	adb shell journalctl --no-pager > ./diag`date +%d%m%Y%H%M%S`/journalctl
	adb shell opkg list > ./diag`date +%d%m%Y%H%M%S`/opkg
	adb shell uname -a > ./diag`date +%d%m%Y%H%M%S`/uname
	adb shell cat /proc/cmdline > ./diag`date +%d%m%Y%H%M%S`/cmdline
	tar czf diag-`date +%d%m%Y%H%M%S`.tgz ./diag`date +%d%m%Y%H%M%S`/*
	rm -rf ./diag`date +%d%m%Y%H%M%S`
	echo "[->] Diagnostics saved to diag-`date +%d%m%Y%H%M%S`.tgz."
}

main() {		## Main subroutine
	echo "[#] webOS-ports diagnostics by HaDAk"
	testadb
	gatherdiag
}

main