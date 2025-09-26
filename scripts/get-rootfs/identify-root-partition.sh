#!/bin/bash

# Script to identify the root partition in a *.img file

if [ $# -ne 1 ]; then
  echo "Usage: $0 <image-file>"
  exit 1
fi

img_file="$1"

# Check if the image file exists
if [ ! -f "$img_file" ]; then
  echo "Image file not found: $img_file"
  exit 1
fi

# Setup loop device with partitions
img_loopdev=$(losetup --show -fP "$img_file")
if [ -z "$img_loopdev" ]; then
  echo "Failed to setup loop device"
  exit 1
fi

echo "Loop device created: $img_loopdev"

# Function to cleanup loop device on exit
cleanup() {
  # Check if loop device still exists before detaching
  if losetup "$img_loopdev" &>/dev/null; then
    losetup -d "$img_loopdev"
  fi
}
trap cleanup EXIT

# Iterate over partitions to find root partition
root_part=""
partitions=$(fdisk -l "$img_loopdev" | grep '^/dev' | awk '{print $1}')
for part in $partitions; do
  # Try to mount partition to a temp dir
  tmp_dir=$(mktemp -d)
  if mount "$part" "$tmp_dir" 2>/dev/null; then
    # Check for root filesystem indicators
    if [ -d "$tmp_dir/etc" ] && [ -d "$tmp_dir/bin" ]; then
      root_part="$part"
      umount "$tmp_dir"
      rmdir "$tmp_dir"
      break
    fi
    umount "$tmp_dir"
  fi
  rmdir "$tmp_dir"
done

if [ -n "$root_part" ]; then
  echo "Root partition identified: $root_part"
else
  echo "Root partition not found"
fi

# Cleanup loop device explicitly (also done on EXIT trap)
if losetup "$img_loopdev" &>/dev/null; then
  losetup -d "$img_loopdev"
fi
