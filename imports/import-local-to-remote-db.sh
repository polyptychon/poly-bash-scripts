#!/bin/bash

function import-local-to-remote-db {
set -e

# load variables
if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

UP=$(pgrep mysql | wc -l);
if [[ "$UP" -ne 1 ]]; then
  echo "Could not connect to local mysql. Exiting..."
  exit
fi

function clean_up
{
  set +e
  rm -rf $PATH_TO_EXPORTS/remote.temp.sql
  rm -rf $PATH_TO_EXPORTS/temp.sql
  set -e
}

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "You want to replace remote db with local to host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N: "
read REPLY
if [[ $REPLY =~ ^[Nn]$ ]]; then
  exit
fi

if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
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
  rsync -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_EXPORTS/remote.temp.sql $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql
  # scp -rCP $SSH_PORT $PATH_TO_EXPORTS/remote.temp.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql"

  #import local converted sql dump file to remote db
ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash <<EOF
cd $REMOTE_PATH
if [[ -f .env ]]; then
  export DB_NAME=\$(sed -n "/DB_NAME/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_NAME'.?.?'//g" | sed -r "s/'\);$//g")
  export DB_USER=\$(sed -n "/DB_USER/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_USER'.?.?'//g" | sed -r "s/'\);$//g")
  export DB_PASSWORD=\$(sed -n "/DB_PASSWORD/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_PASSWORD'.?.?'//g" | sed -r "s/'\);$//g")
  export DB_TABLE_PREFIX=\$(sed -n "/table_prefix/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/^.table_prefix\s?\s?=\s?\s?.//g" | sed -r "s/.;$//g")
  export DOMAIN_NAME_FROM_MYSQL=\$(mysql -u\$DB_USER -p\$DB_PASSWORD -s -N -e "SELECT option_value FROM \$DB_NAME."\$DB_TABLE_PREFIX"options WHERE option_name='siteurl'" | sed -r 's/^http(s)?:\/\///g')
  export LOCAL_DOMAIN=\$(sed -n "/LOCAL_DOMAIN/p" .env | sed -r "s/LOCAL_DOMAIN=//g")
  export REMOTE_DOMAIN=\$(sed -n "/REMOTE_DOMAIN/p" .env | sed -r "s/REMOTE_DOMAIN=//g")
  echo
  if [[ \$DOMAIN_NAME_FROM_MYSQL == \$REMOTE_DOMAIN ]]; then
    echo "REMOTE DOMAIN IN DATABASE: ${bold}${green}\$DOMAIN_NAME_FROM_MYSQL${reset}${reset_bold}"
    echo "REMOTE DOMAIN IN ENV     : ${bold}${green}\$REMOTE_DOMAIN${reset}${reset_bold}"
  else
    echo "REMOTE DOMAIN IN DATABASE: ${bold}${red}\$DOMAIN_NAME_FROM_MYSQL${reset}${reset_bold}"
    echo "REMOTE DOMAIN IN ENV     : ${bold}${red}\$REMOTE_DOMAIN${reset}${reset_bold}"
  fi
  echo
  wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
fi
exit
EOF
elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
  export DB_NAME=$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^.\*/d' | sed -E "s/^.+'database' => '//g" | sed -E "s/',$//g")
  export DB_USER=$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^.\*/d' | sed -E "s/^.+'username' => '//g" | sed -E "s/',$//g")
  export DB_PASSWORD=$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^.\*/d' | sed -E "s/^.+'password' => '//g" | sed -E "s/',$//g")

  mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $PATH_TO_EXPORTS/temp.sql

  rsync -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_EXPORTS/temp.sql $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql

ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash  <<EOF
cd $REMOTE_PATH
export DB_NAME=\$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^.\*/d' | sed -r "s/^.+'database' => '//g" | sed -r "s/',$//g")
export DB_USER=\$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^.\*/d' | sed -r "s/^.+'username' => '//g" | sed -r "s/',$//g")
export DB_PASSWORD=\$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^.\*/d' | sed -r "s/^.+'password' => '//g" | sed -r "s/',$//g")

echo \$DB_NAME

mysql -p\$DB_PASSWORD -u\$DB_USER \$DB_NAME < $PATH_TO_EXPORTS/temp.sql
echo "Success!"
exit
EOF

fi
# perform clean up
clean_up


}
