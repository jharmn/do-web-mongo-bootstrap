#!/bin/bash

# Be sure to set envvar $DOTOKEN (to Digital Ocean Personal API token)...
# Also if QUAYUSER & QUAYTOKEN are set, Quay.io docker images will work

if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ] && [ "$5" != "" ] && [ "$6" != "" ] && [ "$7" != "" ]; then
  REGION=$1
  MONGO_NAME=$2
  WEB_NAME=$3
  DOCKER_IMAGE=$4
  DUMP_FOLDER=$5
  DB_NAME=$6
  TAG=$7
  
  SSH_FINGER=$(./add_ssh.sh)
  
  # Provision mongo
  ./create_mongo.sh $MONGO_NAME $REGION $SSH_FINGER
  MONGO_INFO=./droplet_info.sh $MONGO_NAME
  MONGO_ID=$(echo $MONGO_INFO | ./droplet_id.sh)
  MONGO_IP=$(echo $MONGO_INFO | ./droplet_internal_ip.sh)

  # Restore mongodb$
  ./restore_mongo.sh $MONGO_NAME $DB_NAME $DUMP_FOLDER

  # Provision web application
  ./create_web.sh $WEB_NAME $DOCKER_IMAGE $MONGO_IP $REGION $SSH_FINGER
  WEB_INFO=./droplet_info.sh $WEB_NAME
  WEB_ID=$(echo $WEB_INFO | ./droplet_id.sh)  
  WEB_IP=$(echo $WEB_INFO | ./droplet_internal_ip.sh)

  # Secure droplets
  ./secure_web.sh $WEB_NAME
  ./secure_mongo.sh $MONGO_NAME $WEB_IP

  # Tag droplets
  ./tag_droplet.sh $WEB_ID $TAG
  ./tag_droplet.sh $MONGO_ID $TAG
  
  # Monitoring
  docker-machine ssh $API_NAME docker run -d --name dd-agent -e DD_HOSTNAME=$API_NAME -e TAGS=$TAG -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=$DDTOKEN datadog/docker-dd-agent:latest
  docker-machine ssh $MONGO_NAME docker run -d --name dd-agent -e DD_HOSTNAME=$MONGO_NAME -e TAGS=$TAG -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e API_KEY=$DDTOKEN datadog/docker-dd-agent:latest
  
else
  echo "Invalid syntax: create.sh REGION MONGO_NAME WEB_NAME DOCKER_IMAGE DUMP_FOLDER DB_NAME TAG"
fi
