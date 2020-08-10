#!/bin/bash

set -e
set -x

source layers/poky/oe-init-build-env
bitbake resin-image-flasher
bitbake resin-image-flasher -c populate_sdk

# The Jenkins archiver doesn't follow symlinks. Replace the disk image symlink
# with the actual file.
image_dir=tmp/deploy/images/imx8mm-var-dart
image_file=resin-image-flasher-imx8mm-var-dart.resinos-img
link_path=$image_dir/$image_file
file_path=$image_dir/$(readlink $link_path)
rm -f $link_path
cp $file_path $link_path
