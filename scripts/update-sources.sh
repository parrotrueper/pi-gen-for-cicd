#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR

# shellcheck source=/dev/null
. ci/functions.sh

info "Patch the pi-gen sources"
for patch in scripts/patch-*.sh; do
    run "./$patch"
done
