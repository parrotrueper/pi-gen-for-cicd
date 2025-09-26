#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR


# Script to extract the root partition from <name>.img into <name>-rootfs.tar

if [ $# -ne 1 ]; then
  echo "Usage: $0 <name>"
  echo "This will extract rootfs from <name>.img to <name>-rootfs.tar"
  exit 1
fi

img_file_base="$1"
file_img="${img_file_base}.img"
rootfs_tar="${img_file_base}-rootfs.tar"

# Check if the image file exists
if [ ! -f "$file_img" ]; then
  echo "Image file not found: $file_img"
  exit 1
fi

# Check if tar file already exists
if [ -f "$rootfs_tar" ]; then
  echo "Tar file already exists: $rootfs_tar"
  exit 1
fi

# Setup loop device with partitions
img_loopdev=$(sudo losetup --show -fP "$file_img")
if [ -z "$img_loopdev" ]; then
  echo "Failed to setup loop device"
  exit 1
fi

echo "Loop device created: $img_loopdev"

# Function to cleanup loop device on exit
cleanup() {
  # Check if loop device still exists before detaching
  if sudo losetup "$img_loopdev" &>/dev/null; then
    sudo losetup -d "$img_loopdev"
  fi
}
trap cleanup EXIT

# Iterate over partitions to find root partition
root_part=""
all_partitions=$(sudo fdisk -l "$img_loopdev" | grep '^/dev' | awk '{print $1}')
for part in $all_partitions; do
  # Try to mount partition to a temp dir
  tmp_dir=$(mktemp -d)
  if sudo mount "$part" "$tmp_dir" 2>/dev/null; then
    # Check for root filesystem indicators
    if [ -d "$tmp_dir/etc" ] && [ -d "$tmp_dir/bin" ]; then
      root_part="$part"
      echo "Root partition identified: $root_part"
      # Extract to tar
      echo "Extracting rootfs to $rootfs_tar..."
      sudo tar -cf "$rootfs_tar" -C "$tmp_dir" .
      echo "Extraction complete: $rootfs_tar"
      sudo umount "$tmp_dir"
      rmdir "$tmp_dir"
      break
    fi
    sudo umount "$tmp_dir"
  fi
  rmdir "$tmp_dir"
done

if [ -z "$root_part" ]; then
  echo "Root partition not found"
  exit 1
fi

# Cleanup loop device explicitly (also done on EXIT trap)
if sudo losetup "$img_loopdev" &>/dev/null; then
  sudo losetup -d "$img_loopdev"
fi
