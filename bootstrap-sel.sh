#!/bin/bash
# bootstrap-sel.sh - Boostrap new SEL (development)
#
# * install minimal packages
# * install /etc/selrc
#
# Run bootstrap-sel.sh without a local repo:
#
#     curl https://raw.githubusercontent.com/dtroyer-salad/wsl-ansible/main/bootstrap-sel.sh | bash -s

set -o errexit
set -o xtrace

# Keep track of the current script directory.
TOP_DIR=$(cd $(dirname "$0") && pwd)

# Ensure we have the basics
if [[ -r /etc/os-release ]]; then
  source /etc/os-release
  ID_LIKE=${ID_LIKE:-$ID}
  case "$ID_LIKE" in
    debian)
      # Debian/Ubuntu
      sudo apt-get update
      sudo apt-get -y install curl git gpg make net-tools screen vim wget
      ;;
    fedora)
      # Fedora/RHEL/OEL
      sudo dnf -y install curl git gpg make screen vim wget
      ;;
  esac
fi

if ! $(grep -i "\[boot\]" /etc/wsl.conf >/dev/null); then
    # Add boot section to wsl.conf to run rc.local
    echo -e "[boot]\ncommand = \"/etc/selrc\"" >>/etc/wsl.conf
fi

# Get current selrc
curl -R https://raw.githubusercontent.com/dtroyer-salad/wsl-ansible/main/selrc -o /etc/selrc
chmod 755 /etc/selrc

source /etc/selrc
