if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
  WEB_NAME=$1
  DOCKER_IMAGE=$2
  MONGO_IP=$3
  REGION=$4
  SSH_FINGER=$5

  # Install API
  docker-machine create --driver digitalocean --digitalocean-image "ubuntu-16-04-x64" --digitalocean-size "512mb" \
    --digitalocean-region $REGION --digitalocean-ssh-key-fingerprint "$SSH_FINGER" \
    --digitalocean-private-networking --digitalocean-access-token $DOTOKEN $WEB_NAME 

  # Connect to API box and install docker image
  docker-machine ssh $WEB_NAME "apt-get -y -qq update" 
  docker-machine ssh $WEB_NAME "apt-get -y -qq upgrade"
  eval $(docker-machine env $WEB_NAME)
  if [ $QUAYUSER != "" ] && [ $QUAYTOKEN != "" ]; then
  	docker login -u="$QUAYUSER" -p="$QUAYTOKEN" quay.io
  fi

  docker pull $DOCKER_IMAGE
  docker run -d -e MONGO_HOST=$MONGO_IP -p 80:8080 --restart always --name $WEB_NAME $DOCKER_IMAGE
  docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock centurylink/watchtower

else
  echo "Invalid syntax: create_web.sh WEB_NAME DOCKER_IMAGE MONGO_IP REGION SSH_FINGER"
fi