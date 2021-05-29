#!/bin/bash

. /etc/os-release

sudo apt install -y curl gnupg debian-archive-keyring

echo 'deb http://deb.debian.org/debian buster-backports main' | sudo tee -a /etc/apt/sources.list
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

curl -sL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${VERSION_ID}/Release.key | sudo apt-key add -

sudo apt update
sudo apt -y upgrade

# debian 10 - podman broken dependencies workaround
sudo apt install -y -t buster-backports libseccomp-dev

# install podman
sudo apt install -y podman

# To avoid "write unixgram" error
cat <<EOF | sudo tee -a /etc/containers/containers.conf
[engine]
events_logger = "file"
EOF

# For native Linux only
grep -q WSL /proc/version || sudo sysctl -w kernel.unprivileged_userns_clone=1
grep -q WSL /proc/version || echo "kernel.unprivileged_userns_clone=1" | sudo tee -a /etc/sysctl.conf
