#!/bin/bash

source ${1:-default.cfg}

if [ $WEB_ID=="" ]; then
  WEB_ID=$(./droplet_info.sh $WEB_NAME | ./droplet_id.sh)
fi

if [ $FLOATING_IP!="" ]; then
  curl -X POST -H "Content-Type: application/json" -H \
    "Authorization: Bearer $DOTOKEN" \
    -d "{\"type\":\"assign\", \"droplet_id\": $WEB_ID}" "https://api.digitalocean.com/v2/floating_ips/$FLOATING_IP/actions"
fi
