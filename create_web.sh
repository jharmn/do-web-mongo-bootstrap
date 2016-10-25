#!/bin/bash

source ${1:-default.cfg}

if [ "$SSH_FINGER"=="" ]; then
  SSH_FINGER=$(./ssh_finger.sh)
fi
if [ "$MONGO_IP"=="" ]; then
  MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)
fi

# Install API
docker-machine create --driver digitalocean --digitalocean-image $DO_WEB_IMAGE --digitalocean-size $DO_WEB_SIZE \
  --digitalocean-region $REGION --digitalocean-ssh-key-fingerprint "$SSH_FINGER" \
  --digitalocean-private-networking --digitalocean-access-token $DOTOKEN $WEB_NAME

# Connect to API box and install docker image
if [[ $DO_WEB_IMAGE =~ ^.*ubuntu.*$ ]]; then
  # Update droplet if ubuntu
  docker-machine ssh $WEB_NAME "apt-get -y -qq update"
  docker-machine ssh $WEB_NAME "apt-get -y -qq upgrade"
fi
eval $(docker-machine env $WEB_NAME)
if [ $QUAYUSER != "" ] && [ $QUAYTOKEN != "" ]; then
	docker login -u="$QUAYUSER" -p="$QUAYTOKEN" quay.io
fi

docker pull $DOCKER_IMAGE
docker run -d -e MONGO_HOST=$MONGO_IP -p $WEB_HOST_PORT:$WEB_DOCKER_PORT --restart always --name $WEB_NAME $DOCKER_IMAGE
docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock centurylink/watchtower
