#!/bin/bash

# Be sure to set envvar $DOTOKEN (to Digital Ocean Personal API token)...
# Also if QUAYUSER & QUAYTOKEN are set, Quay.io docker images will work

source ${1:-default.cfg}

# Add SSH fingerprint to DO account
SSH_FINGER=$(./add_ssh.sh)

# Provision mongo
./create_mongo.sh
./prepare_mongo.sh

# Restore mongodb
if [ $DUMP_FOLDER != "" ]; then
  ./restore_mongo.sh
fi

# Provision web droplet
./create_web.sh
./prepare_web.sh
./update_floating_ip.sh

# Secure mongo (must run after web)
./secure_mongo.sh
