#!/bin/bash

# Script to show the first 10 entries in each partition of *.img files

# Function to cleanup loop device on exit
cleanup() {
  if [ -n "$img_loopdev" ] && losetup "$img_loopdev" &>/dev/null; then
    losetup -d "$img_loopdev"
  fi
  if [ -n "$tmp_dir" ] && [ -d "$tmp_dir" ]; then
    umount "$tmp_dir" 2>/dev/null
    rmdir "$tmp_dir" 2>/dev/null
  fi
}
trap cleanup EXIT

# Find all *.img files in current directory and subdirectories
find . -name "*.img" -type f | while read -r img_file; do
  echo "Processing image: $img_file"

  # Check if the image file exists
  if [ ! -f "$img_file" ]; then
    echo "Image file not found: $img_file"
    continue
  fi

  # Setup loop device with partitions
  img_loopdev=$(losetup --show -fP "$img_file")
  if [ -z "$img_loopdev" ]; then
    echo "Failed to setup loop device for $img_file"
    continue
  fi

  echo "Loop device created: $img_loopdev"

  # Get list of partitions
  partitions=$(fdisk -l "$img_loopdev" 2>/dev/null | grep '^/dev' | awk '{print $1}')
  if [ -z "$partitions" ]; then
    echo "No partitions found in $img_file"
    losetup -d "$img_loopdev"
    continue
  fi

  # Iterate over partitions
  for part in $partitions; do
    echo "Processing partition: $part"

    # Create temp directory
    tmp_dir=$(mktemp -d)
    if [ -z "$tmp_dir" ]; then
      echo "Failed to create temp directory for $part"
      continue
    fi

    # Try to mount partition
    if mount "$part" "$tmp_dir" 2>/dev/null; then
      echo "First 10 entries in $part:"
      ls -1 "$tmp_dir" | head -10
      umount "$tmp_dir"
    else
      echo "Failed to mount $part"
    fi

    # Cleanup temp directory
    rmdir "$tmp_dir"
  done

  # Detach loop device
  losetup -d "$img_loopdev"
  echo "Finished processing $img_file"
  echo ""
done

echo "Script completed."
