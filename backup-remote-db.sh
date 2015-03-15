#!/bin/bash
set -e

# load variables
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/temp.sql
}

set +e
git stash
set -e

#create remote sql dump file
ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
cd $REMOTE_PATH
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS --skip-comments --skip-dump-date --skip-opt --add-drop-table
exit
'"
# perform clean up on error
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

#download remote sql dump file
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/

# clean up local sql dump file for less commits
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/remote.sql

# perform clean up
clean_up

# commit changes
set +e
git add $PATH_TO_EXPORTS/remote.sql
git commit -m "backup remote db"
git stash pop
set -e
