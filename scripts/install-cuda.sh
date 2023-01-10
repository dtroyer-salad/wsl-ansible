#!/bin/bash
# install-cuda.sh [-deb|-run] [url]

set -o errexit
set -o xtrace

if [[ -n $1 ]]; then
	if [[ "$1" == "-deb" ]]; then
		DO_DEB=1
		shift
	fi
	if [[ "$1" == "-run" ]]; then
		DO_RUN=1
		shift
	fi
fi

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

SRC_URL=https://developer.download.nvidia.com/compute
if [[ -n $1 ]]; then
	SRC_URL=$1
fi

case $ID in
	debian)
		PKG_BASE=cuda-repo-${ID}${VERSION_ID}-12-0-local
		PKG_VER=12.0.0-525.60.13
		DEB_URL=${SRC_URL}/cuda/12.0.0/local_installers/${PKG_BASE}_${PKG_VER}-1_amd64.deb
		;;
	ubuntu)
		PKG_BASE=cuda-repo-${ID}${VERSION_ID}-12-0-local
		PKG_VER=12.0.0-525.60.13
		DEB_URL=${SRC_URL}/cuda/12.0.0/local_installers/${PKG_BASE}_${PKG_VER}-1_amd64.deb
		PIN_URL=${SRC_URL}/cuda/repos/wsl-ubuntu/x86_64/cuda-ubuntu2204.pin
		;;
	ubuntu-wsl)
		PKG_BASE=cuda-repo-wsl-ubuntu-12-0-local
		PKG_VER=12.0.0
		DEB_URL=${SRC_URL}/cuda/12.0.0/local_installers/${PKG_BASE}_${PKG_VER}-1_amd64.deb
		PIN_URL=${SRC_URL}/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
		;;
	*)
		echo "Unsupported distro: $ID"
		exit 1
		;;
esac

# cuda-toolkit

if [[ -n $DO_DEB ]]; then
	# https://docs.nvidia.com/cuda/wsl-user-guide/index.html
	if [[ -n $PIN_URL ]]; then
		wget -N ${PIN_URL}
		sudo mv cuda-*.pin /etc/apt/preferences.d/cuda-repository-pin-600
	fi
	wget -N ${DEB_URL}
	sudo dpkg -i ${PKG_BASE}_${PKG_VER}-1_amd64.deb
	sudo cp -p /var/${PKG_BASE}/cuda-*-keyring.gpg /usr/share/keyrings/
	sudo apt-get update
	sudo apt-get -y install cuda-toolkit-12-0
fi

if [[ -n $DO_RUN ]]; then
	wget -N ${SRC_URL}/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run
	sudo sh cuda_12.0.0_525.60.13_linux.run --toolkit --silent --override --no-opengl-libs --no-man-page --no-drm 
fi

# nvidia-docker2

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

distribution=${ID}${VERSION_ID}

# Get signing key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# Add signing key to distro
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update
apt-get install -y nvidia-docker2
