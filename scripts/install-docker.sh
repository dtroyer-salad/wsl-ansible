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
elif [[ -n $ID_LIKE ]]; then
        # If ID_LIKE is set use it for non-SEL distros
        ID=$ID_LIKE
fi

DOCKER_URL=${DOCKER_URL:-https://download.docker.com/linux/${ID}/dists/${VERSION_CODENAME}/pool/stable/amd64}
CONTAINERD_URL=containerd.io_1.6.14-1_amd64.deb
DOCKER_CE_URL=docker-ce_20.10.22~3-0~${ID}-${VERSION_CODENAME}_amd64.deb
DOCKER_CE_CLI_URL=docker-ce-cli_20.10.22~3-0~${ID}-${VERSION_CODENAME}_amd64.deb

apt-get update
apt-get install libdevmapper1.02.1

for i in ${CONTAINERD_URL} ${DOCKER_CE_CLI_URL} ${DOCKER_CE_URL}; do
        wget -N ${DOCKER_URL}/$i
        dpkg -i $i
done

/etc/init.d/docker start
