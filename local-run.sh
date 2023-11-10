#!/bin/bash

set -ae

if [ -z "$1" ]; then
    echo "Specify project name as the first argument" && exit 1
fi

# Init default parameters
source "$1.prod.env"

# Override few of them for local run
source "$1.local.env"

docker compose -f ./docker/docker-compose.yml up -d