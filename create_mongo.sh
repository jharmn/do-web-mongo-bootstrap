#!/bin/bash

source ${1:-default.cfg}

if [ "$SSH_FINGER"=="" ]; then
  SSH_FINGER=$(./ssh_finger.sh)
fi
if [ "$MONGO_IP"=="" ]; then
  MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)
fi

# Provision Mongo
docker-machine create --driver digitalocean --digitalocean-image "mongodb" --digitalocean-size $DO_MONGO_SIZE \
  --digitalocean-region $REGION --digitalocean-ssh-key-fingerprint "$SSH_FINGER" \
  --digitalocean-private-networking --digitalocean-access-token $DOTOKEN $MONGO_NAME

# Update droplet
docker-machine ssh $MONGO_NAME "apt-get -y -qq update"
docker-machine ssh $MONGO_NAME "apt-get -y -qq upgrade"

# Change mongod to internal IP
docker-machine ssh $MONGO_NAME sed -i -e "s/127.0.0.1/$MONGO_IP/g" /etc/mongod.conf
docker-machine ssh $MONGO_NAME service mongod restart
