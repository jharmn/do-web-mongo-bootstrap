#!/bin/bash

# Be sure to set envvar $DOTOKEN (to Digital Ocean Personal API token)...
# Also if QUAYUSER & QUAYTOKEN are set, Quay.io docker images will work

if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ] && [ "$5" != "" ] && [ "$6" != "" ] && [ "$7" != "" ]; then
  DOCKER_IMAGE=$1
  DUMP=$2
  DB_NAME=$3
  REGION=$4
  WEB_NAME=$5
  MONGO_NAME=$6
  TAG=$7
  
  SSH_FINGER=$(ssh-keygen -lf ~/.ssh/id_rsa.pub -E md5 | awk '{print $2}' | sed 's/MD5://')
  SSH_PUB=$(cat ~/.ssh/id_rsa.pub)
  HOST_NAME=$(hostname)

  # Add local SSH token
  curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" -d "{\"name\":\"$HOST_NAME\",\"public_key\":\"$SSH_PUB\"}" "https://api.digitalocean.com/v2/account/keys"

  # Provision Mongo
  docker-machine create --driver digitalocean --digitalocean-image "mongodb" --digitalocean-size "512mb" --digitalocean-region $REGION --digitalocean-ssh-key-fingerprint "$SSH_FINGER" --digitalocean-private-networking --digitalocean-access-token $DOTOKEN $MONGO_NAME
  # Get droplet info
  DROPLET_LIST=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/droplets?per_page=200")
  # Get ID for tagging
  MONGO_ID=$(echo $DROPLET_LIST | jq -c ".droplets[] | select(.name | contains(\"$MONGO_NAME\")) | .id")
  # Find private IP
  MONGO_IP=$(echo $DROPLET_LIST | jq -c --raw-output ".droplets[] | select(.name | contains(\"$MONGO_NAME\")) | .networks.v4[] | select(.type | contains(\"private\")) | .ip_address")
  docker-machine ssh $MONGO_NAME "apt-get -y -qq update"
  docker-machine ssh $MONGO_NAME "apt-get -y -qq upgrade"
  # Restore DB
  docker-machine ssh $MONGO_NAME mkdir /root/dump
  docker-machine scp -r $DUMP_FOLDER $MONGO_NAME:/root/dump
  docker-machine ssh $MONGO_NAME mongorestore --db $DB_NAME --drop /root/dump/
  # Change mongod to internal IP
  docker-machine ssh $MONGO_NAME sed -i -e "s/127.0.0.1/$MONGO_IP/g" /etc/mongod.conf
  docker-machine ssh $MONGO_NAME service mongod restart

  # Install API
  docker-machine create --driver digitalocean --digitalocean-image "ubuntu-16-04-x64" --digitalocean-size "512mb" \
    --digitalocean-region $REGION --digitalocean-ssh-key-fingerprint "$SSH_FINGER" \
    --digitalocean-private-networking --digitalocean-access-token $DOTOKEN $WEB_NAME 
  # Get ID for tagging
  DROPLET_LIST=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/droplets?per_page=200")
  WEB_ID=$(echo $DROPLET_LIST | jq -c ".droplets[] | select(.name | contains(\"$WEB_NAME\")) | .id")
  WEB_IP=$(echo $DROPLET_LIST | jq -c --raw-output ".droplets[] | select(.name | contains(\"$WEB_NAME\")) | .networks.v4[] | select(.type | contains(\"private\")) | .ip_address")
  # Connect to API box and install docker image
  docker-machine ssh $WEB_NAME "apt-get -y -qq update" 
  docker-machine ssh $WEB_NAME "apt-get -y -qq upgrade"
  eval $(docker-machine env $WEB_NAME)
  if [ $QUAYUSER != "" ] && [ $QUAYTOKEN != "" ]; then
  	docker login -u="$QUAYUSER" -p="$QUAYTOKEN" quay.io
  fi
  docker pull $DOCKER_IMAGE
  docker run -d -e MONGO_HOST=$MONGO_IP -p 80:8080 --restart always --name $WEB_NAME $DOCKER_IMAGE
  docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock centurylink/watchtower

  # Secure web droplet
  docker-machine ssh $WEB_NAME "apt-get -y install fail2ban"
  docker-machine ssh $WEB_NAME "ufw default deny"
  docker-machine ssh $WEB_NAME "ufw allow ssh"
  docker-machine ssh $WEB_NAME "ufw allow http"
  docker-machine ssh $WEB_NAME "ufw allow 2376" # Docker
  docker-machine ssh $WEB_NAME "ufw --force enable"

  # Secure mongo droplet 
  docker-machine ssh $MONGO_NAME "apt-get -y install fail2ban"
  docker-machine ssh $MONGO_NAME "ufw default deny"
  docker-machine ssh $MONGO_NAME "ufw allow ssh"
  docker-machine ssh $MONGO_NAME "ufw allow 2376" # Docker
  # Add ufw rule to mongo to restrict to only API box
  docker-machine ssh $MONGO_NAME "ufw allow from $WEB_IP/32 to any port 27017"
  docker-machine ssh $MONGO_NAME "ufw --force enable"

  # Tag em all!
  curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DOTOKEN" \
    -d "{\"resources\":[{\"resource_id\":\"$MONGO_ID\",\"resource_type\":\"droplet\"},{\"resource_id\":\"$WEB_ID\",\"resource_type\":\"droplet\"}]}" "https://api.digitalocean.com/v2/tags/$TAG/resources"

  # Monitoring
  docker-machine ssh $API_NAME docker run -d --name dd-agent -e DD_HOSTNAME=$API_NAME -e TAGS=$TAG -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=$DDTOKEN datadog/docker-dd-agent:latest
  docker-machine ssh $MONGO_NAME docker run -d --name dd-agent -e DD_HOSTNAME=$MONGO_NAME -e TAGS=$TAG -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=$DDTOKEN datadog/docker-dd-agent:latest
  
else
  echo "Invalid syntax: create.sh DOCKER_IMAGE DUMP_FOLDER DB_NAME REGION WEB_NAME MONGO_NAME TAG"
fi
