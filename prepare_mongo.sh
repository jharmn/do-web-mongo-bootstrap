#!/bin/bash

source ${1:-default.cfg}

if [ $WEB_IP=="" ]; then
  WEB_IP=$(./droplet_info.sh $WEB_NAME | ./droplet_internal_ip.sh)
fi
if [ $MONGO_ID=="" ]; then
  MONGO_ID=$(./droplet_info.sh $MONGO_NAME | ./droplet_id.sh)
fi

# Tag
./tag_droplet.sh $MONGO_ID $TAG

# Datadog monitoring
if [ $DDTOKEN != "" ]; then
  docker-machine ssh $MONGO_NAME docker run -d --name dd-agent \
    -e DD_HOSTNAME=$MONGO_NAME -e TAGS=$TAG -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
    -e API_KEY=$DDTOKEN datadog/docker-dd-agent:latest
fi
