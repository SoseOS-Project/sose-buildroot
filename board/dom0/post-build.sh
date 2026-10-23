#!/bin/sh
# runs after buildroot puts the dom0 rootfs together, $1 is the target dir

set -e
TARGET_DIR="$1"

# launch-xenstore uses prlimit for xenstored's open file limit, but prlimit
# needs all of util-linux. the shell's ulimit does the same thing
LAUNCH="$TARGET_DIR/etc/xen/scripts/launch-xenstore"
if grep -q 'prlimit --nofile=\$XENSTORED_MAX_OPEN_FDS ' "$LAUNCH"; then
	sed -i 's/prlimit --nofile=\$XENSTORED_MAX_OPEN_FDS /ulimit -n $XENSTORED_MAX_OPEN_FDS; /' "$LAUNCH"
elif ! grep -q 'ulimit -n \$XENSTORED_MAX_OPEN_FDS; ' "$LAUNCH"; then
	echo "post-build: launch-xenstore changed, fix the prlimit swap" >&2
	exit 1
fi

# xen's own vm autostart/shutdown script. svmd does that job, and at shutdown this
# one waits up to 5 min for vms that never answer (the "..." that never ends)
rm -f "$TARGET_DIR/etc/init.d/S60xendomains"

# ship the guest image (build/guest) inside dom0 so vms can boot it from /boot.
# build_sose.sh builds the guest first, a missing one only gets a warning
GUEST="$BASE_DIR/../guest/images/rootfs.cpio.gz"
if [ -f "$GUEST" ]; then
	cp "$GUEST" "$TARGET_DIR/boot/guest.cpio.gz"
else
	echo "post-build: no guest image at $GUEST, vms won't have a filesystem" >&2
fi

# same for the netvm image (build/netvm) that sys-net boots
NETVM="$BASE_DIR/../netvm/images/rootfs.cpio.gz"
if [ -f "$NETVM" ]; then
	cp "$NETVM" "$TARGET_DIR/boot/netvm.cpio.gz"
else
	echo "post-build: no netvm image at $NETVM, sys-net won't boot" >&2
fi
