#!/bin/bash
set -e

# load variables
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/local.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
}

# perform clean up on error
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

#create remote sql dump file
ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/DB_NAME/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_NAME'.?.?'//g" | sed -E "s/'.+//g")
export DB_USER=\$(sed -n "/DB_USER/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_USER'.?.?'//g" | sed -E "s/'.+//g")
export DB_PASSWORD=\$(sed -n "/DB_PASSWORD/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_PASSWORD'.?.?'//g" | sed -E "s/'.+//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF

#download remote sql dump file
scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $PATH_TO_EXPORTS/

#prepare remote sql dump file for local db import
sed -e "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g;s/\<wordpress@$LOCAL_DOMAIN\>/\<wordpress@$REMOTE_DOMAIN\>/g" $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.temp.sql

#import converted sql dump file to local db
wp db import $PATH_TO_EXPORTS/local.temp.sql --path=$PATH_TO_WORDPRESS

# perform clean up
clean_up
