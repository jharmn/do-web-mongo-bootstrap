#!/bin/bash

source ${1:-default.cfg}
MONGO_IP=$(./droplet_info.sh $MONGO_NAME | ./droplet_internal_ip.sh)

./restore_mongo.sh $MONGO_NAME $MONGO_IP $DB_NAME $DUMP_FOLDER 
