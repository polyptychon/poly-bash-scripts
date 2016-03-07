#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function check-uploads() {

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
  PATH_TO_UPLOADS="wp-content/uploads/"
elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
  cd $PATH_TO_DRUPAL
  PATH_TO_UPLOADS="sites/default/files/"
else
  echo "Could not find path! Exiting..."
  exit
fi

trap 'echo -ne "\nExiting..."; cd ..' INT TERM EXIT
find $PATH_TO_UPLOADS '*.*' | while read FILENAME; do
  if [[ $FILENAME == $PATH_TO_UPLOADS ]]; then
    continue
  fi
  if curl --output /dev/null --silent --head --fail "http://$REMOTE_DOMAIN/$FILENAME"
  then
    echo -ne "\r                                                                                                                \r"
    echo -ne "\rFile ${bold}${green} http://$REMOTE_DOMAIN/$FILENAME ${reset}${reset_bold} Exist\r"
  else
    echo "File ${bold}${red} http://$REMOTE_DOMAIN/$FILENAME ${reset}${reset_bold} does not Exist"
  fi
done
cd ..
echo -ne '\n'

}
