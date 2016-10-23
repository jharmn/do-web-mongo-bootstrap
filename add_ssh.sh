HOST_NAME=$(hostname)
SSH_FINGER=$(ssh-keygen -lf ~/.ssh/id_rsa.pub -E md5 | awk '{print $2}' | sed 's/MD5://')
SSH_PUB=$(cat ~/.ssh/id_rsa.pub)

# Add local SSH token
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $DOTOKEN" -d "{\"name\":\"$HOST_NAME\",\"public_key\":\"$SSH_PUB\"}" "https://api.digitalocean.com/v2/account/keys" > /dev/null

echo $SSH_FINGER