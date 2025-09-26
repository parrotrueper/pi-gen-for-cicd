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
repo_url="$(jq -r '.git.url' "$cfg_file")"
repo_branch="$(jq -r '.git.branch' "$cfg_file")"
git_hash=''

# if the repo exists then nuke it and get a fresh clone
if [ -d "$repo_dir" ]; then
    rm -rf "$repo_dir"
fi

info "cloning $repo_dir repo"
run git clone --branch "$repo_branch" "$repo_url"
run pushd "$repo_dir"
    git_hash="$(git rev-parse HEAD)"
run popd

# location for .env file
env_file=".env"
{
  printf "ENV_GIT_HASH=%s\n" "$git_hash"
}>>"${env_file}"


