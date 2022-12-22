#!/bin/bash
# bootstrap.sh - boostrap new WSL
#
# boostrap.sh
#
# * run OS update
# * install minimal packages
# * create ansible user
# * setup home files
#
# Run bootstrap.sh

# Keep track of the current script directory.
TOP_DIR=$(cd $(dirname "$0") && pwd)

GIT_REPO=${GIT_REPO:-https://github.com/dtroyer-salad/wsl-ansible.git}
REPO_DIR=~/src/wsl-ansible

mkdir -p $(dirname ${REPO_DIR})

# Ensure we have the basics - Assumes Debian/Ubuntu
sudo apt-get update
sudo apt-get install ansible git make

if [[ ! -r ${REPO_DIR}/playbooks/bootstrap.yaml ]]; then
  # Retrieve the ansible repo
  git clone $GIT_REPO ${REPO_DIR}
fi
cd ${REPO_DIR}

ansible-playbook playbooks/bootstrap.yaml \
      -i hosts.yaml \
      --extra-vars "host=local-wsl"
