# SoseOS Buildroot tree

The Buildroot external tree that builds the SoseOS dom0. dom0 is tiny on purpose: a kernel plus an initramfs (about 16 MB) that runs completely from RAM and starts clean every boot. Its only job is running Xen's tools and the SoseOS VM manager.

Early and changing a lot. ARM64 only for now, tested in QEMU.

## What's in here

- `configs/sose_dom0_defconfig` - the dom0 config, only what differs from Buildroot's defaults
- `board/dom0/linux-xen.config` - extra kernel options so Linux can run as Xen dom0 from an initramfs
- `board/dom0/post-build.sh` - swaps `prlimit` for `ulimit` in Xen's xenstored launcher so dom0 doesn't need all of util-linux
- `board/dom0/rootfs-overlay/` - files copied into dom0 as is: svmd's init script and the VM configs
- `package/` - svmd, svm and svm-ls from the sose-manager repo, built as Buildroot packages
- `local.mk` - builds the Xen tools from my own Xen tree so they match the hypervisor
- `external.mk` - Xen tools without Xen's own qemu

## Layout it expects

The paths in here are relative, so the folders have to sit like this:

```
SoseOS/
  src/sose/
    buildroot/        this repo
    manager/          sose-manager
  third_party/
    buildroot/        Buildroot 2026.02.3
    xen/              Xen, commit 7e020a4dd6 (4.23)
```

A build repo that sets all of this up in one go is planned.

## Building

From the `SoseOS` folder:

```
# xen itself is built separately
make -C third_party/xen XEN_TARGET_ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- dist-xen

# dom0
make -C third_party/buildroot O=$PWD/build/dom0 BR2_EXTERNAL=$PWD/src/sose/buildroot sose_dom0_defconfig
make -C third_party/buildroot O=$PWD/build/dom0
```

The first dom0 build takes a while (cross compiler, kernel, Xen tools). The result ends up in `build/dom0/images/`.

Buildroot doesn't notice changes in local packages, so after editing manager code run `make ... svmd-rebuild` (or svm / svm-ls) before `make`.

## Booting in QEMU

```
qemu-system-aarch64 \
  -M virt,virtualization=on -cpu cortex-a57 -smp 2 -m 2048 \
  -kernel third_party/xen/xen/xen \
  -append "console=dtuart dom0_mem=512M,max:512M" \
  -device guest-loader,addr=0x50000000,kernel=build/dom0/images/Image,bootargs="console=hvc0" \
  -device guest-loader,addr=0x42000000,initrd=build/dom0/images/rootfs.cpio.gz \
  -nic user,model=virtio-net-pci \
  -serial mon:stdio -display none
```

Log in as `root` (no password), then `svm list`. `Ctrl-A X` quits QEMU.

The kernel has to sit at 0x50000000, QEMU puts its device tree at 0x48000000 and a kernel loaded below that overlaps it.

## License

GPL-2.0-only, see `LICENSE`.
