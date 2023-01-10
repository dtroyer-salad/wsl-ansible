#!/bin/bash
# install-docker.sh

set -o errexit
set -o xtrace

# Get distro info
source /etc/os-release
if [[ "$ID" == "salad-enterprise-linux" ]]; then
        # Currently Debian 11
        ID=debian
        VERSION_CODENAME=bullseye
        VERSION_ID=11
fi

DOCKER_URL=${DOCKER_URL:-https://download.docker.com/linux/${ID}/dists/${VERSION_CODENAME}/pool/stable/amd64}
CONTAINERD_URL=containerd.io_1.6.14-1_amd64.deb
DOCKER_CE_URL=docker-ce_20.10.22~3-0~${ID}-${VERSION_CODENAME}_amd64.deb
DOCKER_CE_CLI_URL=docker-ce-cli_20.10.22~3-0~${ID}-${VERSION_CODENAME}_amd64.deb

sudo apt-get update
sudo apt-get install -y libdevmapper1.02.1

for i in ${CONTAINERD_URL} ${DOCKER_CE_CLI_URL} ${DOCKER_CE_URL}; do
        wget -N ${DOCKER_URL}/$i
        sudo dpkg -i $i
done

sudo /etc/init.d/docker start
