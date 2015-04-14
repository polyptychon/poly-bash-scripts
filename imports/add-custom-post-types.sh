#!/bin/bash

function add-custom-post-types {
  set -e
  if [[ -f ~/wp_scripts/.global-env ]]; then
    source ~/wp_scripts/.global-env
  fi

  if [[ -f .env ]]; then
    source .env
  fi

  DIR_NAME=${PWD##*/}
  ACTIVE_THEME=`wp theme list --status=active --format=csv | grep -o "^.*,active" | sed 's/,active//g'`

  wp scaffold plugin $DIR_NAME-custom-post-types --activate


  #Prompt user for post types
  while (true); do
    echo -n "The singular name of custom post type: "
    read CUSTOM_POST_TYPE_NAME
    wp scaffold post-type $CUSTOM_POST_TYPE_NAME --plugin=$DIR_NAME-custom-post-types
    if [[ -f $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/single.php ]]; then
      cp $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/single.php $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/single-$CUSTOM_POST_TYPE_NAME.php.tmp
      sed -e "s/single.php/single-$CUSTOM_POST_TYPE_NAME.php/g" $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/single-$CUSTOM_POST_TYPE_NAME.php.tmp > $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/single-$CUSTOM_POST_TYPE_NAME.php
      rm -f $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/single-$CUSTOM_POST_TYPE_NAME.php.tmp
    fi
    if [[ -f $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/archive.php ]]; then
      cp $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/archive.php $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/archive-$CUSTOM_POST_TYPE_NAME.php.tmp
      sed -e "s/archive.php/archive-$CUSTOM_POST_TYPE_NAME.php/g" $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/archive-$CUSTOM_POST_TYPE_NAME.php.tmp > $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/archive-$CUSTOM_POST_TYPE_NAME.php
      rm -f $PATH_TO_WORDPRESS/wp-content/themes/$ACTIVE_THEME/archive-$CUSTOM_POST_TYPE_NAME.php.tmp
    fi

    echo -n "Do you want to create another custom post type? [y/n]: "
    read answer
    if [[ $answer == "n" ]]; then
      break;
    fi
  done

  PLUGIN_POST_TYPES_FILES=$PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/post-types/*

  echo "define( 'CUSTOM_POST_TYPES_PLUGIN', __FILE__ );" >> $PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/$DIR_NAME-custom-post-types.php
  echo "define( 'CUSTOM_POST_TYPES_PLUGIN_DIR', untrailingslashit( dirname( CUSTOM_POST_TYPES_PLUGIN ) ) );" >> $PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/$DIR_NAME-custom-post-types.php
  for f in $PLUGIN_POST_TYPES_FILES
  do
    if [[ -d "$PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/post-types" ]]; then
      FNAME="${f##*/}"
      echo "require_once CUSTOM_POST_TYPES_PLUGIN_DIR . '/post-types/$FNAME';" >> $PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/$DIR_NAME-custom-post-types.php
    fi
  done


  PLUGIN_TAXONOMY_FILES=$PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/taxonomies/*

  for f in $PLUGIN_TAXONOMY_FILES
  do
    if [[ -d "$PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/taxonomies" ]]; then
      FNAME="${f##*/}"
      echo "require_once CUSTOM_POST_TYPES_PLUGIN_DIR . '/taxonomies/$FNAME';" >> $PATH_TO_WORDPRESS/wp-content/plugins/$DIR_NAME-custom-post-types/$DIR_NAME-custom-post-types.php
    fi
  done
}
