#!/bin/bash
set -e

# load variables
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/local.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
}

#create remote sql dump file
ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS  --skip-comments --skip-dump-date --skip-opt --add-drop-table
exit
'"

# perform clean up on error
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

#download remote sql dump file
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/

#prepare remote sql dump file for local db import
sed -e "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g;s/\<wordpress@$LOCAL_DOMAIN\>/\<wordpress@$REMOTE_DOMAIN\>/g" $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.temp.sql

#import converted sql dump file to local db
wp db import $PATH_TO_EXPORTS/local.temp.sql --path=$PATH_TO_WORDPRESS

# perform clean up
clean_up
