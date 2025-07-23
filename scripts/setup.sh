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

run scripts/create-docker-assets.sh
run scripts/create-config-file.sh
run scripts/get-sources.sh
run scripts/set-stages.sh

