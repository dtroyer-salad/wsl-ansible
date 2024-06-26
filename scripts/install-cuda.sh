#!/bin/bash
# install-cuda.sh [--deb|--run] [--wsl] [url]

set -o errexit
set -o xtrace

UBUNTU_VERSION=${UBUNTU_VERSION:-2204}

# Default to deb package installs
DO_DEB=1
if [[ -n $1 ]]; then
	if [[ "$1" == "--deb" ]]; then
		DO_DEB=1
		unset DO_RUN
		shift
	fi
	if [[ "$1" == "--run" ]]; then
		DO_RUN=1
		unset DO_DEB
		shift
	fi
	if [[ "$1" == "--wsl" ]]; then
		DO_WSL=1
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
fi

SRC_URL=https://developer.download.nvidia.com/compute
if [[ -n $1 ]]; then
	SRC_URL=$1
fi

case $ID in
	debian)
		if [[ -n $DO_WSL ]]; then
			# Force ubuntu here
			ID=ubuntu
			VERSION_ID=22.04
			PKG_BASE=cuda-repo-wsl-ubuntu-12-0-local
			PKG_VER=12.0.0
			PIN_URL=${SRC_URL}/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
			DEB_URL=${SRC_URL}/cuda/12.0.0/local_installers/${PKG_BASE}_${PKG_VER}-1_amd64.deb
		else
			PKG_BASE=cuda-repo-${ID}${VERSION_ID}-12-0-local
			PKG_VER=12.0.0-525.60.13
			DEB_URL=${SRC_URL}/cuda/12.0.0/local_installers/${PKG_BASE}_${PKG_VER}-1_amd64.deb
		fi
		;;
	ubuntu)
		if [[ -n $DO_WSL ]]; then
			PKG_BASE=cuda-repo-wsl-ubuntu-12-0-local
			PKG_VER=12.0.0
			PIN_URL=${SRC_URL}/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
		else
			PKG_BASE=cuda-repo-${ID}${VERSION_ID}-12-0-local
			PKG_VER=12.0.0
			PIN_URL=${SRC_URL}/cuda/repos/ubuntu${UBUNTU_VERSION}/x86_64/cuda-ubuntu${UBUNTU_VERSION}.pin
		fi
		DEB_URL=${SRC_URL}/cuda/12.0.0/local_installers/${PKG_BASE}_${PKG_VER}-1_amd64.deb
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

sudo apt-get update
sudo apt-get install -y nvidia-docker2

sudo /etc/init.d/docker restart

# Hack-around a difference in Ubuntu and Debian
if [[ ! -r /sbin/ldconfig.real ]]; then
	# nvidia-container-cli expects to find ldconfig.real which doesn't exist on Debian
	sudo ln /sbin/ldconfig /sbin/ldconfig.real
fi
