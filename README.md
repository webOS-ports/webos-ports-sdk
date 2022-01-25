
# webOS Ports SDK

SDK tools for developing apps for LuneOS, either on an emulator, or a real device.

## Installation

Installation is optional -- the scripts can run from anywhere. However, some scripts depend on the original webOS SDK, so the installer checks if it is present, and creates convention-consistent commands in the same install directories. The webOS SDK can be downloaded from sdk.webosarchive.com.

LuneOS development also requires Android developer tools, especially adb.

+ Clone this repo
+ Make the installer executable. 
    + On *nix systems (including Mac): `chmod +x install.sh`
+ Run the installer with elevated privileges:
    + On *nix systems: `.\install.sh`

## Command Line Tools

The command line tools follow the patterns and conventions from the original webOS SDK -- but use the prefix `lune` to specify LuneOS:

<img src="http://sdk.webosarchive.com/docs/images/palm/commands.jpg>


### lune-generate

Wrapper for `palm-generate` to generate LuneOS-ready Enyo apps.

### lune-package

Wrapper for palm-package that prepares an application for installation by converting the files in the application directory to an .ipkg file that you can run on a LuneOS device or Emulator.

`lune-package <path-to-appcode>`

### lune-install

Installs an applicable on a LuneOS device or Emulator.

`lune-install <path-to-ipk>`

### lune-run

Packages, installs, and launches a LuneOS application, then follows the log output.

`lune-run <path-to-appcode>`

### lune-launch

Launches an application installed on a LuneOS device or emulator.

`lune-launch <appid-to-launch>`

### lune-log

Displays web app log messages on the LuneOS device or emulator.

`lune-log`

## Creating a VM

Requires VMWare

+ Create your VM: `scripts/lune-emulator -n webos-ports-dev -i webos-ports-dev-image-qemux86.vmdk create`
+ Generate a diagnostics package: `scripts/lune-diag.sh`
+ Install LuneOS on your emulator: `scripts/lune-emulateos.sh`