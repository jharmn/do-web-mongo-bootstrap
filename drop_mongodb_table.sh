#!/bin/bash

source ${1:-default.cfg}

if [ $1!="" ]; then
  TABLE_NAME=$1

  if [ "$MONGO_IP"=="" ]; then
    MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)
  fi

  MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)

  docker-machine ssh $MONGO_NAME "echo db.$TABLE_NAME.drop\(\) | mongo --host $MONGO_IP $DB_NAME"
else
  echo "Invalid syntax: drop_db.sh TABLE_NAME"
fi
