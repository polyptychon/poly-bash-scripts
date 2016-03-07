#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}
rawurlencode() {
  local string="${1}"
  echo "${string// /%20}"
}
function clear-remote-cache() {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
  cd $PATH_TO_WORDPRESS
  PATH_TO_CACHE="wp-content/cache/"
elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
  cd $PATH_TO_DRUPAL
  PATH_TO_CACHE="wp-content/cache/"
else
  echo "Could not find path! Exiting..."
  exit
fi
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
  cd $REMOTE_PATH
  if [[ -d $PATH_TO_WORDPRESS ]] && [[ -d $PATH_TO_WORDPRESS/$PATH_TO_CACHE ]]; then
    rm -rf $PATH_TO_WORDPRESS/$PATH_TO_CACHE/supercache/*
    wp cache flush
  elif [ -d $PATH_TO_DRUPAL ]  && [[ -d $PATH_TO_WORDPRESS/$PATH_TO_CACHE ]]; then

  fi
  exit
EOF

}
