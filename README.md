
# webOS Ports SDK

SDK tools for developing apps for LuneOS, either on an emulator, or a real device.

## Installation

Installation is optional -- the scripts can run from anywhere. However, some scripts depend on the original webOS SDK, so the installer is checks if it is present, and creates convention-consistent commands in the same install directories. The webOS SDK can be downloaded from sdk.webosarchive.com.

+ Clone this repo
+ Make the installer executable. 
    + On *nix systems (including Mac): `chmod +x install.sh`
+ Run the installer with elevated privileges:
    + On *nix systems: `.\install.sh`

## Creating a VM

Requires VMWare

+ Create your VM: `scripts/lune-emulator -n webos-ports-dev -i webos-ports-dev-image-qemux86.vmdk create`
+ Generate a diagnostics package: `scripts/lune-diag.sh`
+ Install LuneOS on your emulator: `scripts/lune-emulateos.sh`

## Command Line Tools

Follows the naming conventions from webOS SDK:

+ `lune-run <path-to-appcode>`: packages the path and attempts to install it and run it on the connected device or emulator, with console logging enabled (depends on `palm-package` from the webOS SDK)
+ `lune-package <path-to-appcode>`: packages the path (depends on `palm-package` from the webOS SDK)
+ `lune-install <path-to-ipk>`: deploys the specified ipk to the connected device or emulator and attempts to install it
+ `lune-log <ip-address>`: opens a Chrome-based logging window to the device at the specified IP address
