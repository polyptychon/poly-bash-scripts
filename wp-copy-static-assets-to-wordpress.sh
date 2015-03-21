#!/bin/bash
set -e
if [ -f ~/wp_scripts/.global-env ]; then
  source ~/wp_scripts/.global-env
fi

if [ -f .env ]; then
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

gulp production

if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/` ]]; then
  mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/
fi

if [[ `ls -A builds/production/assets/css` ]]; then
  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/css/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/css/
  fi
  cp -Rf builds/production/assets/css/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/css
fi

if [[ `ls -A builds/production/assets/js` ]]; then
  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/js/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/js/
  fi
  cp -Rf builds/production/assets/js/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/js
fi

if [[ `ls -A builds/production/assets/images` ]]; then
  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images/
  fi
  cp -Rf builds/production/assets/images/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images
fi

if [[ `ls -A builds/production/assets/fonts` ]]; then
  if [[ ! `ls -A ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/fonts/` ]]; then
    mkdir ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/fonts/
  fi
  cp -Rf builds/production/assets/fonts/* ../$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/fonts
fi
