#!/bin/bash
set -e
source .env
read -p "You want to replace remote db with local. Are you sure? Y/N " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
backup-remote-db.sh

# import local db to remote
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS --skip-dump-date
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.temp.sql
sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" $PATH_TO_EXPORTS/local.temp.sql > $PATH_TO_EXPORTS/remote.temp.sql
scp -rCP $SSH_PORT $PATH_TO_EXPORTS/remote.temp.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql"

ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
exit
'"
rm -rf exports/local.temp.sql
rm -rf exports/remote.temp.sql
rm -rf exports/temp.sql
fi
