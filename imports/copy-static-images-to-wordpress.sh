#!/bin/bash

function copy-static-images-to-wordpress {
  set -e
  if [[ -f ~/wp_scripts/.global-env ]]; then
    source ~/wp_scripts/.global-env
  fi

  if [[ -f .env ]]; then
    source .env
  fi

  DIR_NAME=${PWD##*/}
  ACTIVE_THEME=`wp theme list --status=active --format=csv | grep -o "^.*,active" | sed 's/,active//g'`

  if [[ -z ${ACTIVE_THEME} ]]; then
    exit
  fi

  if [[ $DIR_NAME != 'static' ]] && [[ `ls -A ./static` ]]; then
    cd ./static
  elif [[ $DIR_NAME == 'static' ]]; then
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
