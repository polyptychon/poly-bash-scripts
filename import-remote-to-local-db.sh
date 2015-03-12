#!/bin/bash
source .env
ssh -p 2222 xarisd@polyptychon.gr bash -c "'

cd $REMOTE_PATH
wp db export exports/temp.sql --path=./wordpress
exit
'"
scp -CP 2222 $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/exports/temp.sql ./exports/
sed 's/-- Dump completed on....................//g' exports/temp.sql > ./exports/remote.sql
sed "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g" exports/remote.sql > exports/local.sql
wp db import exports/local.sql --path=./wordpress
