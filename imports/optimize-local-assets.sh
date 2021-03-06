#!/bin/bash
function optimize-local-assets {
  set -e

  function compress-images-in-folder {
    for f in $1/* ; do
      if [ ${f: -4} == ".png" ] || [ ${f: -4} == ".jpg" ]; then
        echo $f
      fi
      if [ ${f: -4} == ".png" ]; then
        $POLY_SCRIPTS_FOLDER/ewww/optipng -o2 -strip all "$f"
      elif [ ${f: -4} == ".jpg" ]; then
        $POLY_SCRIPTS_FOLDER/ewww/jpegtran -copy none -optimize -perfect "$f" > temp.jpg
        if [ $? = 0 ] && [ -f temp.jpg ]; then
          mv -f temp.jpg "$f"
        elif [ -f temp.jpg ]; then
          rm temp.jpg
        fi
      fi
    done
  }

  # load variables
  if [[ -f .env ]]; then
    source .env
    if [[ -f .env_override ]]; then
      source .env_override
    fi
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
  if [[ -z ${ACTIVE_THEME} ]]; then
    ACTIVE_THEME=${PWD##*/}
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

  #optimize wordpress theme assets
  if [[ -d ./$PATH_TO_WORDPRESS ]] && [[ -d ./$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images ]]; then
    compress-images-in-folder ./$PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/assets/images
  fi

  #optimize static assets images
  if [[ -d ./static/_mockups/images ]]; then
    compress-images-in-folder ./static/_mockups/images
  fi

  #optimize static assets images
  if [[ -d ./_mockups/images ]]; then
    compress-images-in-folder ./_mockups/images
  fi

  #optimize sprite
  if [[ -d ./static/_mockups/sprite ]]; then
    compress-images-in-folder ./static/_mockups/sprite
  fi

  if [[ -d ./_mockups/sprite ]]; then
    compress-images-in-folder ./_mockups/sprite
  fi

  if [[ -d ./$PATH_TO_DRUPAL/sites/all/themes ]]; then
    for img in `find ./$PATH_TO_DRUPAL/sites/all/themes/ -type f -name "*.png" -or -name "*.jpg"`; do
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
  fi
}
