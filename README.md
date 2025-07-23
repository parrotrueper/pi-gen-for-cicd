# Build the raspberry pi OS

Build pi-gen ARM64 branch on a cicd runner, for example on Bitbucket or CircleCi.

## Requirements

### On a local host

* Docker Engine
* qemu
* Enable multiplatform builds
* CLI JSON processor

    `./scripts/host-setup`

### CICD runners

We need a self hosted runner because we need to run docker in priviledged mode.
This applies for both Bitbucket and CircleCi.

On the runner run the following:

    ```shell
    sudo modprobe binfmt_misc
    sudo apt install qemu-user-static
    sudo apt install jq
    ````

## Configuration - build-config.json

### pi-gen config settings

    ```json
    "build":{
        "filename": "auto-gen-config",
        "stages": 2,
        "img_name": "acme-arm64",
        "pi_gen_release": "acme",
        "release": "bookworm",

        "deploy_compression": "xz",
        "compression_level": 9,

        "locale_default": "en_GB.UTF-8",
        "keyboard_keymap": "gb",
        "keyboard_layout": "English (UK)",
        "timezone_default": "Europe/London",

        "target_hostname": "gizmo",
        "first_user_name": "coyote",
        "first_user_pass": "change-me-please",

        "enable_ssh": 1

    }
    ```

### pi-gen branch

    ```json
    "git":{
        "name": "pi-gen",
        "url": "https://github.com/RPI-Distro/pi-gen.git",
        "branch": "arm64"
    },
    ```

### ci docker image

    ```json
    "docker":{
        "name": "cicd_pi_gen",
        "base": "debian:bookworm-20250520-slim",
        "platform": "linux/arm64",
        "build_context": "src/"
    }
    ```

## Pipeline scripts

### CircleCi

Update the config.yml file entry to match your self-hosted runner

`resource_class: wile-e-coyote-limited/road-runner`

### Bitbucket

Should work as is if you have configured a linux shell runner.

## Debugging

Edit file `ci/functions.sh`

    ```shell
    # uncomment to debug CI build, locally
    #CI=true

    is_ci() {
    ```

    ```shell
    ./ci/test
    ```
