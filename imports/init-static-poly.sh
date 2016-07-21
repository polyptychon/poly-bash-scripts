#!/bin/bash
set -e

function init-static-poly {

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

  echo -n " # Path to static build ($PATH_TO_STATIC_BUILD):"
  read PATH_TO_STATIC_BUILD_TEMP
  if [ ! -z ${PATH_TO_STATIC_BUILD_TEMP} ]; then
    PATH_TO_STATIC_BUILD=$PATH_TO_STATIC_BUILD_TEMP
  fi

  echo -n " # git remote origin url ($GIT_REMOTE_ORIGIN_URL):"
  read GIT_REMOTE_ORIGIN_URL_TEMP
  if [ ! -z ${GIT_REMOTE_ORIGIN_URL_TEMP} ]; then
    GIT_REMOTE_ORIGIN_URL=$GIT_REMOTE_ORIGIN_URL_TEMP
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
  echo "PATH_TO_STATIC_BUILD=$PATH_TO_STATIC_BUILD" >> .env
  echo "GIT_REMOTE_ORIGIN_URL=$GIT_REMOTE_ORIGIN_URL" >> .env
else
  echo "WARNING: .env file already exists"
  exit;
fi

}
