#!/bin/bash
set -e
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/local.temp.sql
  rm -rf $PATH_TO_EXPORTS/remote.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
}

read -p "You want to replace remote db with local. Are you sure? Y/N " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
backup-remote-db.sh

# import local db to remote
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS  --skip-comments --skip-dump-date --skip-opt --add-drop-table
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.temp.sql
sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" $PATH_TO_EXPORTS/local.temp.sql > $PATH_TO_EXPORTS/remote.temp.sql
scp -rCP $SSH_PORT $PATH_TO_EXPORTS/remote.temp.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql"

ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
exit
'"
clean_up
fi
