if [ "$1" != "" ]; then
  DROPLET_NAME=$1

  DROPLET_LIST=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" "https://api.digitalocean.com/v2/droplets?per_page=200")
  #echo $DROPLET_LIST
  DROPLET_INFO=$(echo $DROPLET_LIST | jq -c ".droplets[] | select(.name | contains(\"$DROPLET_NAME\"))")
  echo $DROPLET_INFO
else
  echo "Invalid syntax: droplet_info.sh DROPLET_NAME"
fi