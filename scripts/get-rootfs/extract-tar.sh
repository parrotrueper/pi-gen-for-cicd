#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR


# Script to extract a .tar.gz file
# Usage: ./extract_tar.sh <filename.tar.gz>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <tar.gz file>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

result=$(tar -xzf "$1")

if [ "$result" -eq 0 ]; then
    echo "Successfully extracted '$1'"
else
    echo "Error extracting '$1'"
    exit 1
fi
