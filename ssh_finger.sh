#!/bin/bash

SSH_FINGER=$(ssh-keygen -lf ~/.ssh/id_rsa.pub -E md5 | awk '{print $2}' | sed 's/MD5://')
echo $SSH_FINGER
