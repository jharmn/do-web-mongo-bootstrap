#!/bin/bash

source ${1:-default.cfg}

if [ $MONGO_IP=="" ]; then
  MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)
fi

# Restore DB
docker-machine ssh $MONGO_NAME rm -rf /root/dump
docker-machine ssh $MONGO_NAME mkdir /root/dump
docker-machine scp -r "$DUMP_FOLDER" $MONGO_NAME:/root/dump
docker-machine ssh $MONGO_NAME mongorestore --host $MONGO_IP --db $DB_NAME --drop /root/dump/*
