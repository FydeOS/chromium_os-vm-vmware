# Chromium OS VM for VMWare

## TL:DR;
If you aren't bothered with the detailed technicality and are only after the pre-built "click-to-play" image, check out the [release](https://github.com/FydeOS/overlay-variant-amd64-generic-vmware/releases) tab.


## What's this repository
This repository contains necessary files that work with the [Chromium OS SDK](https://www.chromium.org/chromium-os/build) (cros_sdk) to build Chromium OS image that works with VMWare virtual machine client. 


## Why do I need this
VMWare virtual machine clients work on more OS platforms than kvm-qemu, which is the "official VM support for Chromium OS" shipped with cros-sdk. If you are interested in working / testing / tinkering Chromium OS on your favourite OS platform that does not support kvm-qemu natively, this may help. Otherwise, you don't need this.


## How do I build Chromium OS VM for VMWare using this repository

The following is a quick overview guide to get you started. This guide assumes you are comfortable with operations under Linux shell environment and have basic familiarity with the [bible](https://chromium.googlesource.com/chromiumos/docs/+/master/developer_guide.md). 

### 0. Read the [bible](https://chromium.googlesource.com/chromiumos/docs/+/master/developer_guide.md), if you have not yet done so.
It's best if could give the entire process a go and check if you could produce a working Chromium OS image.

### 1. Sync the repo from the correct branch
This overlay was only tested under [release-R75-12105.B](https://chromium.googlesource.com/chromiumos/platform/crosutils/+/refs/heads/release-R75-12105.B) branch of the Chromium OS manifest, per [Get the source code](https://chromium.googlesource.com/chromiumos/docs/+/master/developer_guide.md#get-the-source-code) in the bible, you would need to do the following to get the code:

```
(outside)
cd ${HOME}/chromiumos
repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git -b release-R75-12105.B
repo sync -j4
```

### 2. Clone this overlay and make it known to cros_sdk
 - At this point, you should be in your chroot. 
 - Clone this repository to `~/trunk/src/overlays` under your cros_sdk chroot.
   - Or you can clone to somewhere else and symlink to `~/trunk/src/overlays` for better management
   - This requires a `.local_mounts` file in your `~/trunk/src/scripts` per [here](https://www.chromium.org/chromium-os/tips-and-tricks-for-chromium-os-developers#TOC-How-to-share-files-for-inside-and-outside-chroot).
 - Edit `~/trunk/src/third_party/chromiumos-overlay/eclass/cros-board.eclass` and add `amd64-generic_vmware` to the list. Pay attention to the dash and underscore in the board name, try not to mis-spell.

### 3. Setup board, prepare the host environment and start building
 - Per the bible, now you can do:
   ```
   (inside) export BOARD=amd64-generic_vmware
   (inside) setup_board --board=${BOARD}
   ```
   ~~ `(inside) sudo ~/trunk/src/overlays/overlay-variant-amd64-generic-vmware/prepare_host_env.sh` ~~ 
   ```
   (inside) ./build_packages --board=${BOARD} --nousepkg
   (inside) ./build_image --board=${BOARD} --noenable_rootfs_verification test
   ```
 - Note that the `--nousepkg` flag is required to combat `./build_packages` being lazy to pull pre-built binaries and cause build error.

### 4. Convert the Chromium OS image to VMDK
Assuming the build went well and now you have the `chromiumos_test_image.bin` file. There is this `convert_to_vmware.sh` script in this repository that does the conversion for you. Execute the script to see help.

### 5. Additional notes on using the VMDK file to create VMWare virtual machine
 - We have only tested VMWare Workstation 15 & Fusion 11, lower versions of VMWare clients may not work.
 - You need to create a "Custom VM" and choose "Other Linux kernel 4.x (64 bits)", choose the VMDK file you've just built when prompted.
 - In the Settings of this VM, under "Hard drive" you need to convert bus type from SCSI to either NVMe or SSD.
 - In the Settings of this VM, under "Display", you need to turn on 3D acceleration and ideally allocate 768MB shared memory.
 

## Additional notes and help
 - This Chromium OS VM is only meant for development purposes.
 - To get help, please report any issue in this repo or join our [telegram group](https://t.me/hi_fydeos).
