#!/bin/bash

function optimize-local-uploads {
  set -e

  # load variables
  if [[ -f .env ]]; then
    source .env
    if [[ -f .env_override ]]; then
      source .env_override
    fi
  fi
  if [[ -z $PATH_TO_WORDPRESS ]]; then
    PATH_TO_WORDPRESS="wordpress"
  fi
  if [[ -z $PATH_TO_DRUPAL ]]; then
    PATH_TO_DRUPAL="drupal_site"
  fi

  if [[ ! -f $POLY_SCRIPTS_FOLDER/ewww/optipng ]] || [[ ! -f $POLY_SCRIPTS_FOLDER/ewww/jpegtran ]]; then
    echo "Could not find optipng or jpegtran! Exiting..."
    exit
  fi
  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    PATH_TO_UPLOADS="$PATH_TO_WORDPRESS/wp-content/uploads"
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    PATH_TO_UPLOADS="$PATH_TO_DRUPAL/sites/default/files"
  else
    echo "Could not find path! Exiting..."
    exit
  fi
  for img in `find ./$PATH_TO_UPLOADS/ -type f -name "*.png" -or -name "*.jpg"`; do
    echo "crushing $img ..."
    set +e
    if [ ${img: -4} == ".png" ]; then
      $POLY_SCRIPTS_FOLDER/ewww/optipng -o2 -strip all "$img"
    elif [ ${img: -4} == ".jpg" ]; then
      $POLY_SCRIPTS_FOLDER/ewww/jpegtran -copy none -optimize -perfect "$img" > temp.jpg
      if [ $? = 0 ] && [ -f temp.jpg ]; then
        mv -f temp.jpg "$img"
      fi
    fi
    if [ -f temp.jpg ]; then
      rm temp.jpg
    fi
    set -e
  done

}
