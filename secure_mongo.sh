#!/bin/bash

source ${1:-default.cfg}

if [ $WEB_IP=="" ]; then
  WEB_IP=$(./droplet_info.sh $WEB_NAME | ./droplet_internal_ip.sh)
fi

# Secure mongo droplet
docker-machine ssh $MONGO_NAME "apt-get -y -qq install fail2ban"
docker-machine ssh $MONGO_NAME "ufw default deny"
docker-machine ssh $MONGO_NAME "ufw allow ssh"
docker-machine ssh $MONGO_NAME "ufw allow 2376" # Docker
# Add ufw rule to mongo to restrict to only API box
docker-machine ssh $MONGO_NAME "ufw allow from $WEB_IP/32 to any port 27017"
docker-machine ssh $MONGO_NAME "ufw --force enable"
