#!/bin/bash

. /etc/os-release

sudo apt update
sudo apt install -y curl gnupg debian-archive-keyring

GPGFILE=/usr/share/keyrings/Debian_${VERSION_ID}.gpg
curl -sL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${VERSION_ID}/Release.key | gpg --dearmor | sudo tee ${GPGFILE} > /dev/null

echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" | sudo tee -a /etc/apt/sources.list
echo "deb [signed-by=$GPGFILE] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

sudo apt update
sudo apt -y upgrade

# debian 10 - podman broken dependencies workaround
[ ${VERSION_ID} == "10" ] && sudo apt install -y -t ${VERSION_CODENAME}-backports libseccomp-dev

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

# Install podman-compose
sudo apt install -y python3-pip
sudo pip3 install pyyaml
curl -s https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py | sudo dd of=/usr/local/bin/podman-compose
sudo chmod +x /usr/local/bin/podman-compose
