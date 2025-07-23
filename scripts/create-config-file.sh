#!/usr/bin/env bash
# Exit on error
set -e
set -u
set -o pipefail

# shellcheck source=/dev/null
. ci/functions.sh

# configuration file
cfg_file="build-config.json"

config_filename="$(jq -r '.build.filename' "$cfg_file")"

{
printf "#!/usr/bin/env bash\n\n"

printf "# this script is sourced during the build process\n\n"

# IMG_NAME (Default: raspios-$RELEASE-$ARCH, example: raspios-bookworm-armhf)
#  The name of the image to build with the current stage directories. Use this
#  variable to set the root name of your OS, eg IMG_NAME=Frobulator.
#  Export files in stages may add suffixes to IMG_NAME.
printf "export IMG_NAME=%s\n" "$(jq -r '.build.img_name' "$cfg_file")"

# PI_GEN_RELEASE (Default: Raspberry Pi reference)
#  The release name to use in /etc/issue.txt. The default should only be used
#  for official Raspberry Pi builds.
printf "export PI_GEN_RELEASE=%s\n" "$(jq -r '.build.pi_gen_release' "$cfg_file")"

# RELEASE (Default: bookworm)
#  The release version to build images against. Valid values are any supported
#  Debian release. However, since different releases will have different sets of
#  packages available, you'll need to either modify your stages accordingly, or
#  checkout the appropriate branch. For example, if you'd like to build a
#  bullseye image, you should do so from the bullseye branch.
printf "export RELEASE=%s\n"  "$(jq -r '.build.release' "$cfg_file")"

# APT_PROXY (Default: unset)
#  If you require the use of an apt proxy, set it here.  This proxy setting
#  will not be included in the image, making it safe to use an apt-cacher or
#  similar package for development.

# TEMP_REPO (Default: unset)
#  An additional temporary apt repo to be used during the build process. This
#  could be useful if you require pre-release software to be included in the
#  image. The variable should contain sources in [one-line-style format]
#  (https://manpages.debian.org/stable/apt/sources.list.5.en.html#ONE-LINE-STYLE_FORMAT).
#  "RELEASE" will be replaced with the RELEASE variable.

# BASE_DIR  (Default: location of build.sh)
#  **CAUTION**: Currently, changing this value will probably break build.sh
#  Top-level directory for pi-gen.  Contains stage directories, build
#  scripts, and by default both work and deployment directories.

# WORK_DIR  (Default: $BASE_DIR/work)
#  Directory in which pi-gen builds the target system.  This value can be
#  changed if you have a suitably large, fast storage location for stages to
#  be built and cached.  Note, WORK_DIR stores a complete copy of the target
#  system for each build stage, amounting to tens of gigabytes in the case of
#  Raspbian.
#  **CAUTION**: If your working directory is on an NTFS partition you probably
# won't be able to build: make sure this is a proper Linux filesystem.

# DEPLOY_DIR  (Default: $BASE_DIR/deploy)
#  Output directory for target system images and NOOBS bundles.

# DEPLOY_COMPRESSION (Default: zip)
#  Set to:
#  none to deploy the actual image (.img).
#  zip to deploy a zipped image (.zip).
#  gz to deploy a gzipped image (.img.gz).
#  xz to deploy a xzipped image (.img.xz).
printf "export DEPLOY_COMPRESSION=%s\n" "$(jq -r '.build.deploy_compression' "$cfg_file")"


# DEPLOY_ZIP (Deprecated)
#  This option has been deprecated in favor of DEPLOY_COMPRESSION.
#  If DEPLOY_ZIP=0 is still present in your config file, the behavior is the
#  same as with DEPLOY_COMPRESSION=none.

# COMPRESSION_LEVEL (Default: 6)
#  Compression level to be used when using zip, gz or xz for
#  DEPLOY_COMPRESSION. From 0 to 9 (refer to the tool man page for more
#  information on this. Usually 0 is no compression but very fast, up to 9 with
#  the best compression but very slow ).
printf "export COMPRESSION_LEVEL=%s\n" "$(jq -r '.build.compression_level' "$cfg_file")"

# USE_QEMU (Default: 0)
#  Setting to '1' enables the QEMU mode - creating an image that can be mounted
#  via QEMU for an emulated environment. These images include "-qemu" in the
#  image file name.

# LOCALE_DEFAULT (Default: 'en_GB.UTF-8' )
#  Default system locale.
printf "export LOCALE_DEFAULT=\'%s\'\n" "$(jq -r '.build.locale_default' "$cfg_file")"

# TARGET_HOSTNAME (Default: 'raspberrypi' )
#  Setting the hostname to the specified value.
printf "export TARGET_HOSTNAME=\'%s\'\n" "$(jq -r '.build.target_hostname' "$cfg_file")"

# KEYBOARD_KEYMAP (Default: 'gb' )
#  Default keyboard keymap.
#  To get the current value from a running system, run
#      debconf-show keyboard-configuration
#  and look at keyboard-configuration/xkb-keymap
printf "export KEYBOARD_KEYMAP=\'%s\'\n" "$(jq -r '.build.keyboard_keymap' "$cfg_file")"

# KEYBOARD_LAYOUT (Default: 'English (UK)' )
#  Default keyboard layout.
#  To get the current value from a running system, run
#      debconf-show keyboard-configuration
#  and look at keyboard-configuration/variant
printf "export KEYBOARD_LAYOUT=\'%s\'\n" "$(jq -r '.build.keyboard_layout' "$cfg_file")"

# TIMEZONE_DEFAULT (Default: 'Europe/London' )
#  Default time zone.
#  To get the current value from a running system, look in /etc/timezone
printf "export TIMEZONE_DEFAULT=\'%s\'\n"    "$(jq -r '.build.timezone_default' "$cfg_file")"

# FIRST_USER_NAME (Default: pi)
#  Username for the first user. This user only exists during the image creation
#  process. Unless DISABLE_FIRST_BOOT_USER_RENAME is set to 1, this user
#  will be renamed on the first boot with a name chosen by the final user. This
#  security feature is designed to prevent shipping images with a default
#  username and help prevent malicious actors from taking over your devices.
printf "export FIRST_USER_NAME=\'%s\'\n"     "$(jq -r '.build.first_user_name' "$cfg_file")"


# FIRST_USER_PASS (Default: unset)
#  Password for the first user. If unset, the account is locked.
#  Please change this on first boot
printf "export FIRST_USER_PASS=\'%s\'\n" "$(jq -r '.build.first_user_pass' "$cfg_file")"


# DISABLE_FIRST_BOOT_USER_RENAME (Default: 0)
#  Disable the renaming of the first user during the first boot. This make it so
#  FIRST_USER_NAME stays activated. FIRST_USER_PASS must be set for this to
#  work. Please be aware of the implied security risk of defining a default
#  username and password for your devices.

# WPA_COUNTRY (Default: unset)
#  Sets the default WLAN regulatory domain and unblocks WLAN interfaces. This
#  should be a 2-letter ISO/IEC 3166 country Code, i.e. GB

# ENABLE_SSH (Default: 0)
#  Setting to 1 will enable ssh server for remote log in. Note that if you are
#  using a common password such as the defaults there is a high risk of attackers
#  taking over you Raspberry Pi.
printf "export ENABLE_SSH=%s\n"  "$(jq -r '.build.enable_ssh' "$cfg_file")"

#  PUBKEY_SSH_FIRST_USER (Default: unset)
#  Setting this to a value will make that value the contents of the
#  FIRST_USER_NAME's ~/.ssh/authorized_keys.  Obviously the value should
#  therefore be a valid authorized_keys file.  Note that this does not
#  automatically enable SSH.

#  PUBKEY_ONLY_SSH (Default: 0)
#  Setting to 1 will disable password authentication for SSH and enable
#  public key authentication.  Note that if SSH is not enabled this will take
#  effect when SSH becomes enabled.

# SETFCAP (Default: unset)
#  Setting to 1 will prevent pi-gen from dropping the "capabilities"
#  feature. Generating the root filesystem with capabilities enabled and running
#  it from a filesystem that does not support capabilities (like NFS) can cause
#  issues. Only enable this if you understand what it is.

# STAGE_LIST (Default: stage*)
#  If set, then instead of working through the numeric stages in order, this
#  list will be followed. For example setting to "stage0 stage1 mystage stage2"
#  will run the contents of mystage before stage2. Note that quotes are needed
#  around the list. An absolute or relative path can be given for stages outside
#  the pi-gen directory.

# EXPORT_CONFIG_DIR (Default: $BASE_DIR/export-image)
#
}>"$config_filename"

