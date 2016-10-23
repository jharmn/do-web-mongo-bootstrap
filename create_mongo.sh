if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
  MONGO_NAME=$1
  REGION=$2
  SSH_FINGER=$3

  # Provision Mongo
  docker-machine create --driver digitalocean --digitalocean-image "mongodb" --digitalocean-size "512mb" \
    --digitalocean-region $REGION --digitalocean-ssh-key-fingerprint "$SSH_FINGER" \
    --digitalocean-private-networking --digitalocean-access-token $DOTOKEN $MONGO_NAME
  # Get droplet info
  DROPLET_LIST=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/droplets?per_page=200")
  # Get ID for tagging
  MONGO_ID=$(echo $DROPLET_LIST | jq -c ".droplets[] | select(.name | contains(\"$MONGO_NAME\")) | .id")
  # Find private IP
  MONGO_IP=$(echo $DROPLET_LIST | jq -c --raw-output ".droplets[] | select(.name | contains(\"$MONGO_NAME\")) | .networks.v4[] | select(.type | contains(\"private\")) | .ip_address")
  docker-machine ssh $MONGO_NAME "apt-get -y -qq update"
  docker-machine ssh $MONGO_NAME "apt-get -y -qq upgrade"

  # Change mongod to internal IP
  docker-machine ssh $MONGO_NAME sed -i -e "s/127.0.0.1/$MONGO_IP/g" /etc/mongod.conf
  docker-machine ssh $MONGO_NAME service mongod restart
else
  echo "Invalid syntax: create_mongo.sh MONGO_NAME REGION SSH_FINGER"
fi