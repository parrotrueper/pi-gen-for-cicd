#!/usr/bin/env bash
# Exit on error
set -e

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR

iswsl="no"
# figure out if we are running on Ubuntu native or on WSL
onwsl="/proc/sys/fs/binfmt_misc/WSLInterop"
if [[ -f "${onwsl}" ]]; then
    iswsl="yes"
    echo "WSL host detected"
elif [[ "$(systemd-detect-virt)" != *"none"* ]]; then
    # probably WSL
    echo "Not sure what system you are on, assuming the host OS is Windows"
    echo "If this is not the case things may not go as planned..."
    iswsl="yes"
fi

sudo modprobe binfmt_misc

# for WSL
if [[ "${iswsl}" == "yes" ]]; then
    sudo update-binfmts --enable
fi

sudo apt install qemu-user-static
sudo apt install jq

