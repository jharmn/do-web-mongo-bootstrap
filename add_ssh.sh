#!/bin/bash

. ${1:-default.cfg}

if [ $HOST_NAME=="" ]; then
  HOST_NAME=$(hostname)
fi
if [ $SSH_FINGER=="" ]; then
  SSH_FINGER=$(./ssh_finger.sh)
fi
if [ $SSH_PUB=="" ]; then
  SSH_PUB=$(cat ~/.ssh/id_rsa.pub)
fi

# Add local SSH token
curl -s -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DOTOKEN" \
  -d "{\"name\":\"$HOST_NAME\",\"public_key\":\"$SSH_PUB\"}" "https://api.digitalocean.com/v2/account/keys" > /dev/null

echo $SSH_FINGER
