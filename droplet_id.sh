#!/bin/bash

if [ -t 0 ]; then
  DROPLET_INFO=$1
else
  DROPLET_INFO=$(cat)
fi

echo $DROPLET_INFO | jq -c --raw-output ".id"
