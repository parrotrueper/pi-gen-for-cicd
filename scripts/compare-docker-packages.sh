#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# Error handling
trap 'printf "\n\nERROR at $0 line $LINENO. Exiting.\n\n"' ERR

# shellcheck source=/dev/null
. ci/functions.sh


# Function to extract packages from Dockerfile
extract_packages() {
    local dockerfile="$1"
    local temp_file
    temp_file=$(mktemp)

    # Extract package names from apt-get install command
    # This uses a simple approach to extract package names
    awk '
    BEGIN { found=0 }
    /apt-get.*install/ {
        found=1
        # Remove everything before "install"
        sub(/.*install[^a-zA-Z]*/, "")
    }
    found {
        # Remove backslashes
        gsub(/\\/, "")
        # Split on spaces
        for (i=1; i<=NF; i++) {
            # Skip common non-package words
            if ($i != "--no-install-recommends" &&
                $i != "libarchive-tools" &&
                $i != "libarchive-zip-perl" &&
                $i != "&&" &&
                $i != "rm" &&
                $i != "-rf" &&
                $i != "/var/lib/apt/lists/*" &&
                $i != "install" &&
                $i != "apt-get" &&
                $i !~ /^[;&|]/) {
                print $i
            }
        }
        # Stop at the next command
        if ($0 ~ /[;&|]/) exit
    }
    ' "$dockerfile" |
        grep -v '^$' |
        sort -u >"$temp_file"

    echo "$temp_file"
}

# Function to display differences
display_diff() {
    local file1="$1"
    local file2="$2"
    local label1="$3"
    local label2="$4"

    info "Checking packages in: $label1 vs $label2"

    local only_in_file1
    # Packages only in file1
    only_in_file1=$(comm -23 "$file1" "$file2" | grep -v '^$' || true)
    if [[ -n "$only_in_file1" ]]; then
        w_list=$(echo "" ; echo "${only_in_file1//^/  /}")
        fatal 1 "There are packages in $label1 not included in $label2: $w_list"
    else
        info "$label1 [OK]"
    fi

    # Packages only in file2
    local only_in_file2
    only_in_file2=$(comm -13 "$file1" "$file2" | grep -v '^$' || true)
    if [[ -n "$only_in_file2" ]]; then
        #w_list=$(echo "$only_in_file2" | sed 's/^/  /')
        w_list=$(echo "" ; echo "${only_in_file2//^/  /}")
        fatal 1 "There are packages in $label2 not included in $label1: $w_list"
    else
        info "$label2 [OK]"
    fi

}

main() {
    local_dockerfile="src/Dockerfile"
    remote_dockerfile="pi-gen/Dockerfile"

    # check that the files exist
    if [ ! -f "$local_dockerfile" ]; then
        fatal 1 "$local_dockerfile does not exist"
    fi
    if [ ! -f "$remote_dockerfile" ]; then
        fatal 1 "$remote_dockerfile does not exist"
    fi

    # Extract packages from both Dockerfiles
    src_packages=$(extract_packages "$local_dockerfile")
    pi_gen_packages=$(extract_packages "$remote_dockerfile")

    # debug display summary
    #info "=== Summary ==="
    #info "Packages in src/Dockerfile: $(wc -l <"$src_packages")"
    #info "Packages in pi-gen/Dockerfile: $(wc -l <"$pi_gen_packages")"

    # Display differences
    display_diff "$src_packages" "$pi_gen_packages" "$local_dockerfile" "$remote_dockerfile"

    # Clean up
    rm -f "$src_packages" "$pi_gen_packages"

}

main
