#!/bin/bash

source ${1:-default.cfg}

if [ $WEB_ID=="" ]; then
  WEB_ID=$(./droplet_info.sh $WEB_NAME | ./droplet_id.sh)
fi

# Secure droplet
./secure_web.sh

# Tag
./tag_droplet.sh $WEB_ID $TAG

# Datadog monitoring
if [ $DDTOKEN!="" ]; then
  docker-machine ssh $WEB_NAME docker run -d --name dd-agent \
    -e DD_HOSTNAME=$WEB_NAME -e TAGS=$TAG -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
    -e API_KEY=$DDTOKEN datadog/docker-dd-agent:latest
fi
