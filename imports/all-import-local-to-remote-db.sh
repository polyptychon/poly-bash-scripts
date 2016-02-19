#!/bin/bash

function get_wp_config_value {
  echo `sed -n "/$1/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+$1'.?.?'//g" | sed -E "s/');$//g"`
}

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
}

function all-import-local-to-remote-db {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

LOCAL_PATHS=()
PATH_TO_WORDPRESS=wordpress

if [[ -z $PATH_TO_TEMP_EXPORTS ]]; then
  PATH_TO_TEMP_EXPORTS="temp_dump"
fi

if [[ ! -d $PATH_TO_TEMP_EXPORTS ]]; then
  mkdir $PATH_TO_TEMP_EXPORTS
fi

if [[ ! -z $SSH_HOST ]]; then
  bold=`tput bold`
  red=`tput setaf 1`
  green=`tput setaf 2`
  reset=`tput sgr0`
  reset_bold=`tput rmso`
  echo "import local databases to remote host: ${bold}${red}$SSH_HOST${reset}${reset_bold}"
else
  echo "You must add a SSH_HOST variable to .env file. Exiting..."
  exit
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    PATH_NAME=$(echo $d | sed -E "s/\///g")
    LOCAL_PATHS+=($PATH_NAME)
    cd $d

    if [[ -f .env_override ]]; then
      LOCAL_DOMAIN=`get_env_value 'LOCAL_DOMAIN' '.env_override'`
    else
      LOCAL_DOMAIN=`get_env_value 'LOCAL_DOMAIN'`
    fi

    if [[ -f .env_override ]]; then
      REMOTE_DOMAIN=`get_env_value 'REMOTE_DOMAIN' '.env_override'`
    else
      REMOTE_DOMAIN=`get_env_value 'REMOTE_DOMAIN'`
    fi

    DB_NAME=`get_wp_config_value 'DB_NAME'`
    DB_USER=`get_wp_config_value 'DB_USER'`
    DB_PASSWORD=`get_wp_config_value 'DB_PASSWORD'`

    echo -n " # Remote Domain ($REMOTE_DOMAIN): "
    read REMOTE_DOMAIN_TEMP
    if [ ! -z ${REMOTE_DOMAIN_TEMP} ]; then
      REMOTE_DOMAIN=$REMOTE_DOMAIN_TEMP
    fi

    # export local db to sql dump file
    mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > ../$PATH_TO_TEMP_EXPORTS/temp.sql

    #prepare local sql dump file for remote db import
    sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" ../$PATH_TO_TEMP_EXPORTS/temp.sql > ../$PATH_TO_TEMP_EXPORTS/$PATH_NAME.sql
    cd ..
  fi
done

# rm -rf $PATH_TO_TEMP_EXPORTS
# ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
#   rm -rf $PATH_TO_TEMP_EXPORTS
# EOF

}
