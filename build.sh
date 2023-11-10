#!/bin/bash

# The script with all the commands to build, deploy and maintain the project. It can be executed within the Docker container or locally.

set -ae

################
# Initiazliation
################

# If no arguments - just run the console
if [ $# -eq 0 ]; then
    echo "Runnging bash terminal"
    exec /bin/bash
    exit 0
fi

# The first argument should be your project name (in other words, *.prod.env file name)
if [ -z "$1" ]; then
    echo "Specify project name as the firts argument"
    exit 1
fi

PROJECT=$1

echo "Importing project configuration (environmental variables)"
source "${PROJECT}.prod.env"

# Append configuration to SSH config
echo "Updating SSH config"
mkdir -p "${HOME}/.ssh"
tee -a "${HOME}/.ssh/config" > /dev/null << END
Host ssh.${PROJECT}
ProxyCommand /usr/local/bin/cloudflared access ssh --service-token-id ${CLOUDFLARE_SERVICE_TOKEN_ID} --service-token-secret ${CLOUDFLARE_SERVICE_TOKEN_SECRET} --hostname %h  
User app
IdentityFile ${SSH_KEYS_FOLDER}/${PROJECT}.app.id_ed25519
IdentitiesOnly yes
StrictHostKeyChecking no

END

##########
# Commands
##########

# If it was only one argument (project name) - run bash with all the env vars/configs initiated
if [ $# -eq 1 ]; then
    echo "Runnging bash terminal"
    exec /bin/bash
    exit 0
fi

# Access node via SSH
if [[ "$*" == *"--ssh"* ]]; then 
    echo "Connecting via SSH"
    ssh app@ssh."${PROJECT}"
    exit 0
fi

# Generate new SSH keys to access node
if [[ "$*" == *"--new-keys"* ]]; then 
    echo "Generating new SSH keys"
    mkdir -p "${SSH_KEYS_FOLDER}"
    rm -r "${SSH_KEYS_FOLDER}/$PROJECT.*" || echo 
    ssh-keygen -t ed25519 -C "root" -f "${SSH_KEYS_FOLDER}/$PROJECT.root.id_ed25519" -N ""
    ssh-keygen -t ed25519 -C "app" -f "${SSH_KEYS_FOLDER}/$PROJECT.app.id_ed25519" -N ""
fi

# Init terraform
if [[ "$*" == *"--init-infra"* ]]; then 
    echo "Initiating Terraform"
    terraform -chdir=infra init
fi

# Destroy infrastructure
if [[ "$*" == *"--destroy-infra"* ]]; then 
    echo "Destroying infrastructure"
    terraform -chdir=infra destroy
fi

# Deploy terraform
if [[ "$*" == *"--deploy-infra"* ]]; then 
    echo "Creating infrastructure"
    terraform -chdir=infra apply -auto-approve
fi

# Build and push images to registry
if [[ "$*" == *"--publish"* ]]; then 
    echo "Pushing application images to the registry"
    docker context use default
    docker login "${DOCKER_REGISTRY}" -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}"

    docker buildx build --platform linux/arm64 --push -t "${DOCKER_REGISTRY}/${DOCKER_USER}/$1/nginx:latest" ./docker/nginx
    docker buildx build --platform linux/arm64 --push -t "${DOCKER_REGISTRY}/${DOCKER_USER}/$1/ghost:latest" ./docker/ghost
    docker buildx build --platform linux/arm64 --push -t "${DOCKER_REGISTRY}/${DOCKER_USER}/$1/kopia:latest" ./docker/kopia                                                                                                                   
fi

# Deploy Docker containers
if [[ "$*" == *"--deploy-app"* ]]; then 
    echo "Deploying application to Docker"
    docker context create "${PROJECT}" --docker "host=ssh://app@ssh.${PROJECT}" || echo "Context already exists"
    docker context use "${PROJECT}"
    docker login "${DOCKER_REGISTRY}" -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}"

    if [[ "$*" == *"--pull"* ]]; then 
        docker compose -f ./docker/docker-compose.yml pull
    fi
    docker compose -f ./docker/docker-compose.yml up -d                                                                                                                      
fi

echo "Finihed"

# Restore DB manually
if [[ "$*" == *"--restore-db"* ]]; then 
    echo "Restoring DB"
    docker context create "${PROJECT}" --docker "host=ssh://app@ssh.${PROJECT}" || echo "Context already exists"
    docker context use "${PROJECT}"
    docker login "${DOCKER_REGISTRY}" -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}"

    docker stop ghost
    docker exec -it kopia restore.sh
    docker start ghost                                                                                                                     
fi