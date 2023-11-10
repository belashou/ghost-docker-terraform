#!/bin/bash

docker build --tag builder .
docker run -it --rm --name builder \
  -v $(pwd):/project:z \
  -v /Users/belashou/.ssh/ghost:/root/.ssh/ghost:z \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder \
  inshort.dev --new-keys