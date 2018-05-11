

Create your VM by:

```
scripts/webosvbox -n webos-ports-dev -i webos-ports-dev-image-qemux86.vmdk create
```

Generate a diagnostics package:
```
scripts/diag.sh
```
Install webOS-Ports on your Google Nexus 7:
```
scripts/install_webos.sh
```
