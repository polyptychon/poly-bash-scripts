#!/bin/bash
set -e
source .env
ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
exit
'"
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/remote.sql
sed "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g" $PATH_TO_EXPORTS/remote.sql > $PATH_TO_EXPORTS/local.sql
wp db import $PATH_TO_EXPORTS/local.sql --path=$PATH_TO_WORDPRESS
