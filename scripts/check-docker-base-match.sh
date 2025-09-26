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

# pi-gen docker builder
pi_gen_docker_sh="pi-gen/build-docker.sh"


# Function to extract BASE_IMAGE from build-docker.sh
get_base_image() {
    if [[ -f "$pi_gen_docker_sh" ]]; then
        # Extract the BASE_IMAGE value from the docker build command
        grep -o 'BASE_IMAGE=[^[:space:]]*' "$pi_gen_docker_sh" | sed 's/BASE_IMAGE=//' | head -1
    else
        echo ""
    fi
}

# Main function
main() {
    info "Checking Docker base image consistency..."

    # Check if files exist
    if [[ ! -f "$cfg_file" ]]; then
        fatal 1 "$cfg_file not found"
    fi

    if [[ ! -f "$pi_gen_docker_sh" ]]; then
        fatal 1 "$pi_gen_docker_sh not found"
    fi

    # Get values
    our_base="$(jq -r '.docker.base' "$cfg_file")"
    raspi_base=$(get_base_image)

    info "$cfg_file docker.base: $our_base"
    info "$pi_gen_docker_sh BASE_IMAGE: $raspi_base"

    # Check if values are empty
    if [[ -z "$our_base" ]]; then
        fatal 1 "Could not extract docker.base from $cfg_file"
    fi

    if [[ -z "$raspi_base" ]]; then
        fatal 1 "Could not extract BASE_IMAGE from $pi_gen_docker_sh"
    fi

    # Compare values
    if [[ "$our_base" == "$raspi_base" ]]; then
        info "Values match!"
    else
        fatal 1 "Expected: $raspi_base  Actual: $our_base"
    fi
}

# Run main function
main
