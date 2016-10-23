#!/bin/bash

# Be sure to set envvar $DOTOKEN (to Digital Ocean Personal API token)...

if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
  HOST=$1
  DOMAIN=$2
  DOCKER_NAME=$3
  IP_ADDRESS=$(docker-machine ip $DOCKER_NAME)
 
  HOST_ID=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/domains/$DOMAIN/records" | jq -c ".domain_records[] | select(.name == \"$HOST\") | select(.type == \"A\") | .id")
  if [ $HOST_ID != "" ]; then
    curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" -d "{\"data\":\"$IP_ADDRESS\"}" "https://api.digitalocean.com/v2/domains/$DOMAIN/records/$HOST_ID"
  else
    echo "Host ID not found!"
  fi
else
  echo "Invalid syntax: update_domain.sh HOST DOMAIN DOCKER_NAME"
fi
