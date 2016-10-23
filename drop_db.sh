#!/bin/bash
if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
  MONGO_NAME=$1
  DB_NAME=$2
  TABLE_NAME=$3

  MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)

  docker-machine ssh mongo-1 "echo db.$TABLE_NAME.drop\(\) | mongo --host $MONGO_IP $DB_NAME"
else
  echo "Invalid syntax: drop_db.sh MONGO_NAME DB_NAME TABLE_NAME"
fi
