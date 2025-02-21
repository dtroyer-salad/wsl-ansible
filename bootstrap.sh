#!/bin/bash
# bootstrap.sh - Boostrap new WSL
#
# * run OS update
# * install minimal packages
# * create ansible user
# * setup home files
#
# Run bootstrap.sh without a local repo:
#
#     curl https://raw.githubusercontent.com/dtroyer-salad/wsl-ansible/main/bootstrap.sh | bash -s

set -o errexit
set -o xtrace

# Keep track of the current script directory.
TOP_DIR=$(cd $(dirname "$0") && pwd)

GIT_REPO=${GIT_REPO:-https://github.com/dtroyer-salad/wsl-ansible.git}
REPO_DIR=${REPO_DIR:-~/src/wsl-ansible}

mkdir -p $(dirname ${REPO_DIR})

# Get current selrc
curl -R https://raw.githubusercontent.com/dtroyer-salad/wsl-ansible/main/selrc | sudo tee /etc/selrc
sudo chmod 755 /etc/selrc
sudo bash /etc/selrc

# Ensure we have the basics
if [[ -r /etc/os-release ]]; then
  source /etc/os-release
  ID_LIKE=${ID_LIKE:-$ID}
  case "$ID_LIKE" in
    debian)
      # Debian/Ubuntu
      sudo apt-get update
      sudo apt-get -y upgrade
      sudo apt-get -y install ansible curl git gpg make screen vim wget
      ;;
    fedora)
      # Fedora/RHEL/OEL
      sudo dnf -y install ansible-core curl git gpg make screen vim wget
      ansible-galaxy collection install ansible.posix chocolatey.chocolatey community.crypto
      ;;
  esac
fi

if ! $(grep -i "\[boot\]" /etc/wsl.conf >/dev/null); then
    # Add boot section to wsl.conf to run selrc
    echo -e "[boot]\ncommand = \"/etc/selrc\"" >>/etc/wsl.conf
fi

if [[ ! -r ${REPO_DIR}/playbooks/bootstrap.yaml ]]; then
  # Retrieve the ansible repo
  git clone $GIT_REPO ${REPO_DIR}
fi
cd ${REPO_DIR}

# Do Ansible bootstrap
ansible-playbook playbooks/bootstrap.yaml \
      -i hosts.yaml \
      --extra-vars "host=local-wsl"

# Get the dotfiles repo and install
make dotfiles
cd ../dotfiles
. .homefuncs
install_home
