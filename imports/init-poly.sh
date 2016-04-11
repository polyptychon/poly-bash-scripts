#!/bin/bash
set -e

function init-poly {

DIR_NAME=${PWD##*/}

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

if [[ -f .env ]]; then
  echo "${bold}${red}.env${reset}${reset_bold} file already exists!"
  exit
fi
if [[ -z $DEFAULT_WP_USER ]]; then
  echo "You must define a DEFAULT_WP_USER variable in .global-env. example: DEFAULT_WP_USER=admin"
  echo "Exiting..."
  exit
fi

WP_USER=$DEFAULT_WP_USER
WP_USER_PASSWORD="$(date | md5)"
DB_NAME="$(echo -e "${PWD##*/}" | sed -e 's/[[:space:]]/_/g;s/-/_/g')"

while (true); do

  echo -n " # SSH HOST ($SSH_HOST): "
  read SSH_HOST_TEMP
  if [ ! -z ${SSH_HOST_TEMP} ]; then
    SSH_HOST=$SSH_HOST_TEMP
  fi

  echo -n " # SSH PORT ($SSH_PORT): "
  read SSH_PORT_TEMP
  if [ ! -z ${SSH_PORT_TEMP} ]; then
    SSH_PORT=$SSH_PORT_TEMP
  fi

  echo -n " # SSH USERNAME ($SSH_USERNAME): "
  read SSH_USERNAME_TEMP
  if [ ! -z ${SSH_USERNAME_TEMP} ]; then
    SSH_USERNAME=$SSH_USERNAME_TEMP
  fi

  echo -n " # Remote SSH domains root path ($REMOTE_SSH_ROOT_PATH): "
  read REMOTE_SSH_ROOT_PATH_TEMP
  if [ ! -z ${REMOTE_SSH_ROOT_PATH_TEMP} ]; then
    REMOTE_SSH_ROOT_PATH=$REMOTE_SSH_ROOT_PATH_TEMP
  fi

  echo -n " # Remote host database prefix ($REMOTE_DB_NAME_PREFIX): "
  read REMOTE_DB_NAME_PREFIX_TEMP
  if [ ! -z ${REMOTE_DB_NAME_PREFIX_TEMP} ]; then
    REMOTE_DB_NAME_PREFIX=$REMOTE_DB_NAME_PREFIX
  fi

  echo -n " # Relative path to wordpress ($PATH_TO_WORDPRESS): "
  read PATH_TO_WORDPRESS_TEMP
  if [ ! -z ${PATH_TO_WORDPRESS_TEMP} ]; then
    PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS_TEMP
  fi

  echo -n " # Relative path to exports ($PATH_TO_EXPORTS): "
  read PATH_TO_EXPORTS_TEMP
  if [ ! -z ${PATH_TO_EXPORTS_TEMP} ]; then
    PATH_TO_EXPORTS=$PATH_TO_EXPORTS_TEMP
  fi

  echo -n " # Local Database name ($DB_NAME): "
  read DB_NAME_TEMP
  if [ ! -z ${DB_NAME_TEMP} ]; then
    DB_NAME=$DB_NAME_TEMP
  fi

  echo -n " # Local Database user ($DB_USER): "
  read DB_USER_TEMP
  if [ ! -z ${DB_USER_TEMP} ]; then
    DB_USER=$DB_USER_TEMP
  fi

  echo -n " # Local Database password ($DB_PASSWORD): "
  read DB_PASSWORD_TEMP
  if [ ! -z ${DB_PASSWORD_TEMP} ]; then
    DB_PASSWORD=$DB_PASSWORD_TEMP
  fi

  echo -n " # Wordpress admin user ($WP_USER): "
  read WP_USER_TEMP
  if [ ! -z ${WP_USER_TEMP} ]; then
    WP_USER=$WP_USER_TEMP
  fi

  if [ ! -f admin-password.txt ]; then
    echo -n " # Wordpress admin password ($WP_USER_PASSWORD):"
    read WP_USER_PASSWORD_TEMP
    if [ ! -z ${WP_USER_PASSWORD_TEMP} ]; then
      WP_USER_PASSWORD=$WP_USER_PASSWORD_TEMP
    fi
  fi

  echo -n " # Wordpress admin email ($WP_USER_EMAIL):"
  read WP_USER_EMAIL_TEMP
  if [ ! -z ${WP_USER_EMAIL_TEMP} ]; then
    WP_USER_EMAIL=$WP_USER_EMAIL_TEMP
  fi

  FOLDER="$(pwd)"
  echo -n "You are in folder ${bold}${red}$FOLDER${reset}${reset_bold}. Do you want to continue? [y/n]: "
  read answer
  if [[ $answer == "y" ]]; then
    break;
  elif [[ $answer == "n" ]]; then
    exit;
  fi

done

if [ ! -f .env ]; then
  echo "SSH_HOST=$SSH_HOST" > .env
  echo "SSH_PORT=$SSH_PORT" >> .env
  echo "SSH_USERNAME=$SSH_USERNAME" >> .env
  echo "REMOTE_DOMAIN=$DIR_NAME.$SSH_HOST" >> .env
  echo "LOCAL_DOMAIN=$DIR_NAME.local:8888" >> .env
  echo "REMOTE_PATH=$REMOTE_SSH_ROOT_PATH/$DIR_NAME" >> .env
  echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> .env
  echo "PATH_TO_EXPORTS=$PATH_TO_EXPORTS" >> .env
  echo "WP_USER_EMAIL=$WP_USER_EMAIL" >> .env
else
  echo "WARNING: .env file already exists"
  exit;
fi

if [ ! -f admin-password.txt ]; then
  echo "WP_USER_PASSWORD: $WP_USER_PASSWORD" > ./admin-password.txt
fi

}
