#!/bin/bash

function backup-remote-db {
set -e

# load variables
source .env

function clean_up
{
  set +e
  rm -rf $PATH_TO_EXPORTS/remote.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
  git stash pop --quiet
  set -e
}

# perform clean up on error
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

set +e
git stash --quiet
set -e

#create remote sql dump file
if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then

ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/DB_NAME/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_NAME'.?.?'//g" | sed -E "s/'.+//g")
export DB_USER=\$(sed -n "/DB_USER/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_USER'.?.?'//g" | sed -E "s/'.+//g")
export DB_PASSWORD=\$(sed -n "/DB_PASSWORD/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_PASSWORD'.?.?'//g" | sed -E "s/'.+//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF

elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then

ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'database' => '//g" | sed -E "s/',$//g")
export DB_USER=\$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'username' => '//g" | sed -E "s/',$//g")
export DB_PASSWORD=\$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'password' => '//g" | sed -E "s/',$//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF

else
  clean_up
  echo "Can not backup remote database"
  exit;
fi

#download remote sql dump file
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/

# clean up local sql dump file for less commits
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/remote.sql

# commit changes
set +e
git add $PATH_TO_EXPORTS/remote.sql
git commit -m "backup remote db"
set -e
# perform clean up
clean_up

}
