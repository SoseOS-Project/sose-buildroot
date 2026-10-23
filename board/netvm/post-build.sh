#!/bin/sh
# runs after buildroot puts the netvm rootfs together, $1 is the target dir

set -e
TARGET_DIR="$1"
INIT="$TARGET_DIR/etc/init.d"

# xen's tools come with dom0's init scripts too. xenstored, the watchdog and
# vm autostart only belong in dom0, sys-net would try to run its own xenstore
rm -f "$INIT/S50xencommons" "$INIT/S50xen-watchdog" "$INIT/S60xendomains"

# xen's driver domain script starts `xl devd`, which plugs other vms' network
# cards in here. it has no S number, so busybox init would never run it
if [ -f "$INIT/xendriverdomain" ]; then
	mv "$INIT/xendriverdomain" "$INIT/S60xendriverdomain"
fi
