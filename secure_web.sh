#!/bin/bash

source ${1:-default.cfg}

# Secure web droplet
docker-machine ssh $WEB_NAME "apt-get -y install fail2ban"
docker-machine ssh $WEB_NAME "ufw default deny"
docker-machine ssh $WEB_NAME "ufw allow ssh"
docker-machine ssh $WEB_NAME "ufw allow http"
docker-machine ssh $WEB_NAME "ufw allow 2376" # Docker
docker-machine ssh $WEB_NAME "ufw --force enable"
