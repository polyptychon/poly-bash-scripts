#!/bin/bash
set -e
source .env
ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS --skip-dump-date --compact --add-drop-table
exit
'"
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/remote.temp.sql
sed "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g" $PATH_TO_EXPORTS/remote.temp.sql > $PATH_TO_EXPORTS/local.temp.sql
wp db import $PATH_TO_EXPORTS/local.temp.sql --path=$PATH_TO_WORDPRESS
rm -rf exports/local.temp.sql
rm -rf exports/remote.temp.sql
rm -rf exports/temp.sql
