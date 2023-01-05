# Windows Ansible Bits

Run all parts:

	make all

Targets:

	* backup - Install backup bits
    * bootstrap - Basic WSL configuration
    * dotfiles - $HOME configuration files from a personal repo

Bootstrap a new server without cloning the repo locally:

    curl https://raw.githubusercontent.com/dtroyer-salad/wsl-ansible/main/bootstrap.sh | bash -s
