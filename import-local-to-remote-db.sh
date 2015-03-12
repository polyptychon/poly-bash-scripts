#!/bin/bash
set -e
source .env
backup-remote-db.sh

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
