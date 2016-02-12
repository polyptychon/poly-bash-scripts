#!/bin/bash

function import-remote-to-local-db {
set -e

# load variables
source .env

function clean_up
{
  set +e
  rm -rf $PATH_TO_EXPORTS/local.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
  set -e
}
function get_drupal_config_value {
  echo `sed -n "/\'$1\'.\=\>/p" $PATH_TO_DRUPAL/sites/default/settings.php | sed -E "s/.+\'$1\'.\=\>//g" | sed -E "s/\'\,$//g" | sed -E "s/\'//g" | sed -E "s/$1|password|username|databasename|(\/path\/to\/databasefilename)//g"`
}

# perform clean up on error
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

#create remote sql dump file
if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then

ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/DB_NAME/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_NAME'.?.?'//g" | sed -r "s/'.+//g")
export DB_USER=\$(sed -n "/DB_USER/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_USER'.?.?'//g" | sed -r "s/'.+//g")
export DB_PASSWORD=\$(sed -n "/DB_PASSWORD/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_PASSWORD'.?.?'//g" | sed -r "s/'.+//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF

elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then

ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -r "s/^.+'database' => '//g" | sed -r "s/',$//g")
export DB_USER=\$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -r "s/^.+'username' => '//g" | sed -r "s/',$//g")
export DB_PASSWORD=\$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -r "s/^.+'password' => '//g" | sed -r "s/',$//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF

else
  clean_up
  echo "Can not import remote database"
  exit;
fi
#download remote sql dump file
rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/
# scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/

#import converted sql dump file to local db
if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
  #prepare remote sql dump file for local db import
  sed -e "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g;s/\<wordpress@$LOCAL_DOMAIN\>/\<wordpress@$REMOTE_DOMAIN\>/g" $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.temp.sql
  wp db import $PATH_TO_EXPORTS/local.temp.sql --path=$PATH_TO_WORDPRESS
elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
  DB_NAME=`get_drupal_config_value 'database'`
  DB_USER=`get_drupal_config_value 'username'`
  DB_PASSWORD=`get_drupal_config_value 'password'`
  mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME < $PATH_TO_EXPORTS/temp.sql
fi

# perform clean up
clean_up
}
