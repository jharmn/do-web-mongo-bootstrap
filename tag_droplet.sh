if [ "$1" != "" ] && [ "$2" != "" ]; then
  DROPLET_ID=$1
  TAG=$2

# Tag em all!
  curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DOTOKEN" \
    -d "{\"resources\":[{\"resource_id\":\"$DROPLET_ID\",\"resource_type\":\"droplet\"}]}" "https://api.digitalocean.com/v2/tags/$TAG/resources"
else
  echo "Invalid syntax: tag_droplet.sh DROPLET_ID TAG"
fi