if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ]; then
  MONGO_NAME=$1
  DB_NAME=$2
  DUMP_FOLDER=$3

  # Restore DB
  docker-machine ssh $MONGO_NAME mkdir /root/dump
  docker-machine scp -r $DUMP_FOLDER $MONGO_NAME:/root/dump
  docker-machine ssh $MONGO_NAME mongorestore --db $DB_NAME --drop /root/dump/
else
  echo "Invalid syntax: restore_mongo.sh MONGO_NAME DB_NAME DUMP_FOLDER"
fi