if [ "$1" != "" ] && [ "$2" != "" ]; then
  MONGO_NAME=$1
  WEB_IP=$2

  # Secure mongo droplet 
  docker-machine ssh $MONGO_NAME "apt-get -y -qq install fail2ban"
  docker-machine ssh $MONGO_NAME "ufw default deny"
  docker-machine ssh $MONGO_NAME "ufw allow ssh"
  docker-machine ssh $MONGO_NAME "ufw allow 2376" # Docker
  # Add ufw rule to mongo to restrict to only API box
  docker-machine ssh $MONGO_NAME "ufw allow from $WEB_IP/32 to any port 27017"
  docker-machine ssh $MONGO_NAME "ufw --force enable"
else
  echo "Invalid syntax: secure_mongo.sh MONGO_NAME WEB_IP"
fi