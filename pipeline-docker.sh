#!/bin/bash
set -e

docker network create votingapp || true

#cleanup
docker rm -f myvotingapp || true
docker rm -f myredis || true

#build
docker build \
    -t rocioguadalupe/votingapp \
    ./src/votingapp

docker run \
    --name myredis \
    --network votingapp \
    -d redis

docker run \
    --name myvotingapp \
    --network votingapp \
    -p 8080:80 \
    -e REDIS="myredis:6379" \
    -d rocioguadalupe/votingapp

# test
docker build \
    -t rocioguadalupe/votingapp-test \
    ./test

docker run \
    --rm -e VOTINGAPP_HOST="myvotingapp" \
    --network votingapp \
    rocioguadalupe/votingapp-test

#delivery
docker push rocioguadalupe/votingapp