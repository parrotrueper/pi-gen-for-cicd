# RaspbiOS Docker base image

`docker pull parrotrueper/raspbios-trixie-lite:latest`

## Build your own

Build a minimal raspbian image based on the latest version of RPi-Distro pi-gen.

The result file from a local build or a pipeline build is `deploy.tar.gz`

The rootfs partition can then be used to create a Docker base image.

```shell
docker import -m <message> --platform=linux/arm64/v8 ./rootfs.tar <image name>
```

For example

```shell
docker import -m "raspbios trixie lite" --platform=linux/arm64/v8 ./2025-09-17-raspbios-trixie-arm64-lite-rootfs.tar raspbios-lite-20250917:latest
```

The image can then be pushed to docker hub

```shell
docker login -u <username>
docker image tag <image name> <docker hub namespace>/<image name>
docker image push -a <docker hub namespace>/<image name>
```

See helper scripts in `scripts/get-rootfs` to extract and tar the rootfs partition of
the img file.
