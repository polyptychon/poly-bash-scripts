#!/bin/bash

function copy-static-images-to-wordpress {
  set -e

  if [[ -f .env ]]; then
    source .env
    if [[ -f .env_override ]]; then
      source .env_override
    fi
  fi

  if [ -z $PATH_TO_WORDPRESS ] || [ ! -d $PATH_TO_WORDPRESS ]; then
    echo "Can not find wordpress installation. Exiting..."
    exit;
  fi

  if [ ! -d static ]; then
    echo "Can not find static folder. Exiting..."
    exit;
  fi

  if [ ! -d static/node_modules ]; then
    echo "Please run 'npm install' first. Exiting..."
    exit;
  fi

  DIR_NAME=${PWD##*/}
  ACTIVE_THEME=`wp theme list --status=active --format=csv | grep -o "^.*,active" | sed 's/,active//g'`

  if [[ -z ${ACTIVE_THEME} ]]; then
    exit
  fi

  if [[ $DIR_NAME != 'static' ]] && [[ `ls -A ./static` ]]; then
    cd ./static
  elif [[ $DIR_NAME -eq 'static' ]]; then
    cd .
  else
    exit
  fi

  NODE_ENV=production gulp images

  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/
  fi

  if [[ `ls -A builds/production/assets/images` ]]; then
    if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images/` ]]; then
      mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images/
    fi
    cp -Rf builds/production/assets/images/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images
  fi
}
