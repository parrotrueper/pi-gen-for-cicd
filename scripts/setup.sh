#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR

# shellcheck source=/dev/null
. ci/functions.sh

# Check that jq is installed
if ! command -v jq >/dev/null 2>&1; then
    err "This script requires \"jq\". Please instal the package..."
    warn "sudo apt install jq"
    info "Alternatively you can install all the local host dependencies with"
    warn "./scripts/host-setup"
    exit 1
fi

info "Setup the build environment"

# create .env file for docker
run scripts/create-docker-assets.sh
# config file to use with pi-gen
run scripts/create-config-file.sh
# pi-gen github sources
run scripts/get-sources.sh
# check that pi-gen has not changed dependencies
run scripts/compare-docker-packages.sh
# check that the debian base image has not changed
run scripts/check-docker-base-match.sh
# patch the sources with our changes
run scripts/update-sources.sh

