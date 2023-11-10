#!/bin/bash

# The script installs all the required tools for macOS to run and develop the project

set -e

# Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Ansible
brew install ansible
ansible-galaxy collection install community.docker

# Cloudflared Client
brew install cloudflare/cloudflare/cloudflared

# Setup SSH (macOS)
tee -a ~/.ssh/config << END

Host ssh.${1}
  ProxyCommand /opt/homebrew/bin/cloudflared access ssh --service-token-id ${CLOUDFLARE_SERVICE_TOKEN_ID} --service-token-secret ${CLOUDFLARE_SERVICE_TOKEN_SECRET} --hostname %h
  User app
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/ghost/${1}.app.id_ed25519
  IdentitiesOnly yes 

END