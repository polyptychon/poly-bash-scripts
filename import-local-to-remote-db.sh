#!/bin/bash
set -e
source .env
# backup remote db
ssh -p 2222 xarisd@polyptychon.gr bash -c "'
cd $REMOTE_PATH
wp db export exports/temp.sql --path=./wordpress
exit
'"
scp -CP 2222 $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/exports/temp.sql ./exports/
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' exports/temp.sql > ./exports/remote.sql
sed "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g" exports/remote.sql > exports/local.sql

set +e
git add exports/.
git commit -m "backup remote db"
set -e

# import local db to remote
wp db export exports/temp.sql --path=./wordpress
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' exports/temp.sql > exports/local.sql
sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" exports/local.sql > exports/remote.sql
scp -rCP 2222 exports/remote.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/exports/temp.sql"

ssh -p 2222 xarisd@polyptychon.gr bash -c "'
cd $REMOTE_PATH
wp db import exports/temp.sql --path=./wordpress
exit
'"
