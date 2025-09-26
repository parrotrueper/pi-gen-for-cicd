#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR

# Script to extract <something>.zip

# the zip file matching the pattern
zip_file=$1

if [ ! -f "$zip_file" ]; then
	echo "Error: No file matching $zip_file found"
	exit 1
fi

if [[ $zip_file == *.zip ]]; then

	echo "Extracting ..."

	# Extract the zip file
	result=$(unzip "$zip_file" -d ./)

	if [ "$result" -eq 0 ]; then
		echo "Extraction successful."
	else
		echo "Error: Extraction failed."
		exit 1
	fi

else
	echo "Error: $zip_file is not a .zip file"
	exit 1
fi
