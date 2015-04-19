#!/bin/bash

function copy-static-styles-to-wordpress {
  set -e

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

  NODE_ENV=production gulp sass

  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/
  fi

  if [[ `ls -A builds/production/assets/css` ]]; then
    if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/css/` ]]; then
      mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/css/
    fi
    cp -Rf builds/production/assets/css/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/css
  fi
}