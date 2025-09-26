#!/usr/bin/env bash

#-------------------------------------------------------------------
# This collection of helper functions is sourced by the ci scripts.
#-------------------------------------------------------------------

# Defaults.
declare -i VERBOSITY=${VERBOSITY:-1}

# shellcheck source=/dev/null
. ci/ansi

run() {
  ansi --green-intense --newline "[RUN] $*"
  "$@"
}

err() {
  ansi --bold --red --newline "[ERROR] Line: ${BASH_LINENO[0]}   $*"
}

fatal(){
  err_code=$1
  shift
  ansi --bold --red --newline "[ERROR] Line: ${BASH_LINENO[0]}   $*"
  exit "$err_code"

}

info() {
  ansi --cyan --newline "[INFO] $*"
}

pass() {
  ansi --bold --green --newline "[PASS] $*"
  echo
}

expect_fail() {
  ansi --green-intense --newline "[RUN] $*"
  set +e
  ( "$@" )
  RC=$?
  set -e

  if [ ${RC} -eq 0 ]; then
    err "Expected command to fail, but it succeeded: $*"
    exit 1
  else
    pass "Command failed as expected: $*"
  fi
}

warn() {
  ansi --yellow-intense --newline "[WARN] $*"
}

debug() {
  if [[ ${VERBOSITY} -ge 2 ]]; then
    ansi --yellow-intense --newline "[DEBUG] $*"
  fi
}

finish() {
  declare -ri RC=$?

  if [ ${RC} -eq 0 ]; then
    pass "$0 OK"
  else
    err "$0" failed with exit code ${RC}
  fi
}

# uncomment to debug CI build, locally
#CI=true

is_ci() {
  if [ -n "${CI-}" ]; then
    # not empty
    if [[ "$CI" = true ]]; then
      echo "yes"
    else
      echo "no"
    fi
  elif [ "${CI+defined}" = defined ]; then
    # empty but defined
    echo "no"
  else
     # unset
     echo "no"
  fi
}

check_top_dir() {
  declare git_dir
  git_dir="$(git rev-parse --show-toplevel)"
  readonly git_dir

  if ! [[ "$PWD" == "${git_dir}" ]]; then
    err Please run these scripts from the root of the repo
    exit 1
  fi
  echo "${git_dir}"
}

# Traps.
# NOTE: In POSIX, beside signals, only EXIT is valid as an event.
#       You must use bash to use ERR.
trap finish EXIT
