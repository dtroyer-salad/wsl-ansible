# Salad WSL Setup

INVENTORY=--inventory-file=hosts.yaml
VAULT_PW = --vault-password-file $(HOME)/.saladpwd
SECRETS = --extra-vars @secrets.yaml $(VAULT_PW)

ifdef HOST
	EXTRA := $(EXTRA) host=$(HOST)
else
	EXTRA := $(EXTRA) host=local-wsl
endif

ifdef EXTRA
	EXTRA := --extra-vars "$(EXTRA)"
endif

ARGS = $(OPTS) $(EXTRA)

all: bootstrap dotfiles backup

backup:
	ansible-playbook $(INVENTORY) $(ARGS) playbooks/backup.yaml

bootstrap:
	ansible-playbook $(INVENTORY) $(ARGS) playbooks/bootstrap.yaml

dotfiles:
	ansible-playbook $(INVENTORY) $(ARGS) playbooks/dotfiles.yaml

# Maintain secrets

edit-secrets:
	ansible-vault edit $(VAULT_PW) secrets.yaml

encrypt-string:
	ansible-vault encrypt_string $(VAULT_PW) "$(VAL)"

.PHONY: edit-secrets
