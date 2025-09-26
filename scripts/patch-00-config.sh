#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR

# shellcheck source=/dev/null
. ci/functions.sh

# configuration file
cfg_file="build-config.json"

repo_dir="$(jq -r '.git.name' "$cfg_file")"

# remove the stock config file so we can replace it with our own version
config_filename="$(jq -r '.build.filename' "$cfg_file")"
info "removing stock config file"
run rm -rf "$repo_dir/config"
info "replacing with auto generated config file"
run cp "$config_filename" "$repo_dir/config"

info "patch in build script for a ci build"
run cp scripts/cicd-build.sh "$repo_dir/"
run chmod +x "$repo_dir/cicd-build.sh"

info "add in ci container command script"
run mv entrycmd.sh "$repo_dir/"
run chmod +x "$repo_dir/entrycmd.sh"
