#!/bin/bash
set -e

# load variables
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/remote.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
}

read -p "You want to replace remote db with local. Are you sure? Y/N " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

  #backup remote db
  wp-backup-remote-db.sh

  # perform clean up on error
  trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

  # export local db to sql dump file
  wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS  --skip-comments --skip-dump-date --skip-opt --add-drop-table

  #prepare local sql dump file for remote db import
  sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/remote.temp.sql

  #upload local converted sql dump file to remote ssh server
  scp -rCP $SSH_PORT $PATH_TO_EXPORTS/remote.temp.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql"

  #import local converted sql dump file to remote db
  ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
  cd $REMOTE_PATH
  wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
  exit
  '"
  # perform clean up
  clean_up

fi
