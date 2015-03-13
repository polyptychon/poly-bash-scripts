#!/bin/bash
set -e
source .env
backup-remote-db.sh

# import local db to remote
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.sql
sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" $PATH_TO_EXPORTS/local.sql > $PATH_TO_EXPORTS/remote.sql
scp -rCP $SSH_PORT $PATH_TO_EXPORTS/remote.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql"

ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
exit
'"
git checkout $PATH_TO_EXPORTS/local.sql
git checkout $PATH_TO_EXPORTS/remote.sql
