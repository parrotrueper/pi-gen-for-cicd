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

  stages="$(jq -r '.build.stages' "$cfg_file")"
  case ${stages} in
    5);&
    4);&
    3);&
    2);;
    *)
      err "-s ${stages} not supported"
      exit 1
     ;;
  esac

  repo_dir="$(jq -r '.git.name' "$cfg_file")"
  if [[ ${stages} -le 4 ]]; then
      touch "$repo_dir/stage5/SKIP"
      touch "$repo_dir/stage5/SKIP_IMAGES"
  fi
  if [[ ${stages} -le 3 ]]; then
      touch "$repo_dir/stage4/SKIP"
      touch "$repo_dir/stage4/SKIP_IMAGES"
  fi
  if [[ ${stages} -le 2 ]]; then
      touch "$repo_dir/stage3/SKIP"
  fi

