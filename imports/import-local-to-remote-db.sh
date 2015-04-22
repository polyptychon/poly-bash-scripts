#!/bin/bash

function import-local-to-remote-db {
set -e

# load variables
source .env

function clean_up
{
  set +e
  rm -rf $PATH_TO_EXPORTS/remote.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
  set -e
}

if [ -z $PATH_TO_WORDPRESS ] || [ ! -d $PATH_TO_WORDPRESS ]; then
  echo "Can not find wordpress installation. Exiting..."
  exit;
fi

echo -n "You want to replace remote db with local. Are you sure? Y/N: "
read REPLY
if [[ $REPLY =~ ^[Yy]$ ]]
then
  #backup remote db
  set +e
  source $POLY_SCRIPTS_FOLDER/imports/commit-remote-db.sh
  commit-remote-db
  set -e

  # perform clean up on error
  trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

  function get_wp_config_value {
    echo `sed -n "/$1/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+$1'.?.?'//g" | sed -E "s/');$//g"`
  }

  DB_NAME=`get_wp_config_value 'DB_NAME'`
  DB_USER=`get_wp_config_value 'DB_USER'`
  DB_PASSWORD=`get_wp_config_value 'DB_PASSWORD'`

  # export local db to sql dump file
  mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $PATH_TO_EXPORTS/temp.sql

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
}
