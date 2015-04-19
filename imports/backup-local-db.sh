#!/bin/bash

function backup-local-db {
  set -e

  # load variables
  source .env

  function clean_up
  {
    set +e
    rm -rf $PATH_TO_EXPORTS/local.temp.sql
    rm -rf $PATH_TO_EXPORTS/temp.sql
    git stash pop --quiet
    set -e
  }

  # perform clean up on error
  trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

  set +e
  git stash --quiet
  set -e

  function get_wp_config_value {
    echo `sed -n "/$1/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+$1'.?.?'//g" | sed -E "s/');$//g"`
  }
  DB_NAME=`get_wp_config_value 'DB_NAME'`
  DB_USER=`get_wp_config_value 'DB_USER'`
  DB_PASSWORD=`get_wp_config_value 'DB_PASSWORD'`

  # export local db to sql dump file
  mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $PATH_TO_EXPORTS/temp.sql

  # clean up local sql dump file for less commits
  sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.sql

  # commit changes
  set +e
  git add $PATH_TO_EXPORTS/local.sql
  git commit -m "backup local db"
  set -e

  # perform clean up
  clean_up
}
