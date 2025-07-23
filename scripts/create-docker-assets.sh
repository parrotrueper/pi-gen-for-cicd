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

# location for .env file
env_file=".env"

# entry command script for the container
entrycmd="entrycmd.sh"

is_arm=0
# check our architecture
case $(uname -m) in
    arm*) is_arm=1
        ;;
esac

info "generate .env for docker compose"
{
    printf "DKR_BASE_IMG=%s\n" "$(jq -r '.docker.base' "$cfg_file")"
    printf "DKR_PLATFORM=%s\n" "$(jq -r '.docker.platform' "$cfg_file")"
    printf "DKR_IMAGE_NAME=%s\n" "$(jq -r '.docker.name' "$cfg_file")"
    printf "DKR_BLD_CONTEXT=%s\n" "$(jq -r '.docker.build_context' "$cfg_file")"

    printf "ENV_USER_ID=%s\n" "$(id -u)"
    printf "ENV_USER_GID=%s\n" "$(id -g)"

    printf "DKR_HOST_DIR=%s\n"  "$(jq -r '.git.name' "$cfg_file")"

}>"${env_file}"

info "generate the entry command script for the container"
if [[ is_arm -eq 0 ]]; then
    {
        printf "#!/usr/bin/env bash"
        printf "\nset -e"
        printf "\nset -o pipefail"

        printf "\ndpkg-reconfigure qemu-user-static \\"
        printf "\n && (mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true) \\"
        printf "\n && ./cicd-build.sh\n"

    }>"${entrycmd}"
else
    {
        printf "#!/usr/bin/env bash\n\n"
        printf "./cicd-build.sh\n"
    }>"${entrycmd}"
fi
