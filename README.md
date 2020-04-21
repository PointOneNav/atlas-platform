# Atlas Yocto Repository

This repository contains everything needed to build the host operating system for a Point One Atlas hardware platform.
See https://github.com/PointOneNav/nautilus/tree/develop/point_one/platform/atlas for details.

It is a fork of the [balena-variscite-mx8 repository](https://github.com/balena-os/balena-variscite-mx8). Currently, the
only customizations are:

- Update the Variscite i.MX layer submodule to include support for the i.MX 8M Mini (the processor variant used by
  Atlas)
- Added pre-defined Yocto configuration files in `build/conf/`

## Cloning The Repository

This repository contains submodules for all of the Yocto meta-layers that must be initialized.

To clone the repository, including all submodules, do the following:

```
git clone git@github.com:PointOneNav/atlas-platform.git --recursive
```

Alternatively, you can initialize submodules explicitly:

```
git clone git@github.com:PointOneNav/atlas-platform.git
cd atlas-platform
git submodule update --init --recursive
```

## Prerequisites

Before starting the Yocto build, you must install the following requirements:

- Yocto host dependencies (see
  https://www.yoctoproject.org/docs/latest/brief-yoctoprojectqs/brief-yoctoprojectqs.html#packages):
  ```
  sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
  build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
  xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
  pylint3 xterm
  ```
- Docker
  1. Go to https://docs.docker.com/install/linux/docker-ce/ubuntu/
  2. Follow the "Set Up The Repository" and "Install Docker Engine" instructions
  3. Setup a `docker` user group on your machine so you don't need `sudo` to use Docker
     (https://docs.docker.com/install/linux/linux-postinstall/):
     ```
     sudo groupadd docker
     sudo usermod -aG docker $USER
     newgrp docker
     ```
## Building

> Normally, you need to create Yocto build settings and layer configuration files (`local.conf` and `bblayers.conf`)
> before starting a build. These have been created already and are checked into this repository in `build/conf/`.

Before running any Yocto builds, you must first source the environment setup script:

```
source layers/poky/oe-init-build-env build
```

Now you can build the Atlas host OS target as follows:

```
bitbake resin-image-flasher
```

This will generate the file `build/tmp/deploy/images/imx8mm-var-dart/resin-image-flasher-imx8mm-var-dart.resinos-img`,
which contains the a _flasher_ image. The flasher image can be loaded onto an SD card and inserted into an Atlas device.
On boot, the image will automatically copy the host operating system to the onboard eMMC flash memory (see
[Loading A Device](#loading-a-device)).

If needed, you can generate the Yocto SDK, which contains the cross-compilation tools and supporting files, by running
the following:

```
bitbake resin-image-flasher -c populate_sdk
```

This will generate the file
`build/tmp/deploy/sdk/balena-os-glibc-x86_64-resin-image-flasher-aarch64-toolchain-2.5.2.sh`.

## Loading A Device

Atlas devices are designed to boot off of onboard eMMC flash memory. The `resin-flasher-image` target generates an image
designed to be loaded onto an SD card. When booted, the flasher then automatically loads the host operating system
itself into the eMMC.

To load a device:

1. Build the flasher image (see [Building](#building)).
2. Insert an SD card into your computer and load the image onto it using one of the following options:
   - Use the [Balena Etcher](https://www.balena.io/etcher/) utility
   - Load the image using the Balena CLI
     ```
     balena local flash build/tmp/deploy/images/imx8mm-var-dart/resin-image-flasher-imx8mm-var-dart.resinos-img --drive /dev/disk -y
     ```
     where `/dev/disk` is the device node of the SD card (e.g., `/dev/mmcblk1`)
   - Load the image manually using `dd`:
     ```
     sudo dd if=build/tmp/deploy/images/imx8mm-var-dart/resin-image-flasher-imx8mm-var-dart.resinos-img of=/dev/mmcblk1
     ```
3. Power down the device.
4. Switch the `Boot Select` jumper to `SD CARD`.
5. Insert the SD card and power up the device.
6. Wait until all of the LEDs turn off, indicating the eMMC update is complete.
7. Power down the device.
8. Switch the `Boot Select` jumper to `eMMC` and remove the SD card.
9. Power up the device.