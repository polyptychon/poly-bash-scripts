#!/bin/bash
set -e
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/local.temp.sql
  rm -rf $PATH_TO_EXPORTS/remote.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
}

ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS  --skip-comments --skip-dump-date --skip-opt --add-drop-table
exit
'"
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/remote.temp.sql
sed -e "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g;s/\<wordpress@$LOCAL_DOMAIN\>/\<wordpress@$REMOTE_DOMAIN\>/g" $PATH_TO_EXPORTS/remote.temp.sql > $PATH_TO_EXPORTS/local.temp.sql
wp db import $PATH_TO_EXPORTS/local.temp.sql --path=$PATH_TO_WORDPRESS
#mysql -p -u $LOCAL_DATABASE_USERNAME $LOCAL_DATABASE < $PATH_TO_EXPORTS/local.temp.sql
clean_up
