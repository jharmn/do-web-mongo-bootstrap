#!/bin/bash

if [ $1!="" ]; then
  docker-machine stop $1
  docker-machine rm -y $1
  rm -rf ~/.docker/machine/machines/$1
else
  echo "Invalid syntax: destroy.sh NAME"
fi
