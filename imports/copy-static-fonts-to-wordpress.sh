#!/bin/bash

function copy-static-fonts-to-wordpress {
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
  if [ -z $ACTIVE_THEME ] || [ ! -d $PATH_TO_WORDPRESS/wp-content/themes/$DIR_NAME ]; then
    ACTIVE_THEME=`wp theme list --status=active --format=csv | grep -o "^.*,active" | sed 's/,active//g'`
  fi
  if [[ -z ${ACTIVE_THEME} ]]; then
    if [[ -d $PATH_TO_WORDPRESS/wp-content/themes/$DIR_NAME ]]; then
      ACTIVE_THEME=$DIR_NAME
    else
      echo "Could not find theme folder. Exiting..."
      exit
    fi
  fi

  if [[ $DIR_NAME != 'static' ]] && [[ `ls -A ./static` ]]; then
    cd ./static
  else
    echo "Could not find static folder. Exiting..."
    exit
  fi

  NODE_ENV=production gulp fonts

  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/
  fi

  if [[ `ls -A builds/production/assets/fonts` ]]; then
    if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/fonts/` ]]; then
      mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/fonts/
    fi
    cp -Rf builds/production/assets/fonts/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/fonts
  fi
}
