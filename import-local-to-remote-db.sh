#!/bin/bash
source .env
wp db export exports/temp.sql --path=./wordpress
sed 's/-- Dump completed on....................//g' exports/temp.sql > exports/local.sql
sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" exports/local.sql > exports/remote.sql
scp -rCP 2222 exports/remote.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/exports/temp.sql"
