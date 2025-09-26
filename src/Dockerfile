ARG BASE_IMAGE=debian:bookworm
FROM ${BASE_IMAGE}

COPY docker-data/bashrc /etc/bash.bashrc

RUN apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    arch-test \
    bc \
    binfmt-support \
    ca-certificates \
    coreutils \
    curl \
    debootstrap \
    dosfstools \
    e2fsprogs \
    file \
    fdisk \
    git \
    gpg \
    grep \
    kmod \
    libarchive-tools \
    libcap2-bin \
    parted \
    pigz \
    quilt \
    qemu-user-static \
    rsync \
    udev \
    vim \
    xz-utils \
    xxd \
    zerofree \
    zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/workspace
# to update the path edit docker-data/.bashrc
ENV PATH="$PATH"
SHELL ["/usr/bin/bash", "-c"]
RUN source /etc/bash.bashrc

