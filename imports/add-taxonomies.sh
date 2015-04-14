#!/bin/bash

function add-taxonomies {
  set -e

  if [[ -f .env ]]; then
    source .env
  fi

  DIR_NAME=${PWD##*/}

  wp scaffold plugin $DIR_NAME-custom-post-types --activate


  #Prompt user for post types
  while (true); do
    echo -n "The name of the taxonomy: "
    read CUSTOM_TAXONOMY_NAME

    echo -n "Post types to register for use with the taxonomy: "
    read CUSTOM_POST_TYPES

    wp scaffold taxonomy $CUSTOM_TAXONOMY_NAME --plugin=$DIR_NAME-custom-post-types --post_types=$CUSTOM_POST_TYPES

    echo -n "Do you want to generate terms for taxonomy $CUSTOM_TAXONOMY_NAME? [y/n]: "
    read generate_answer
    if [[ $generate_answer == "y" ]]; then
      wp term generate $CUSTOM_TAXONOMY_NAME --count=10
    fi

    echo -n "Do you want to create another taxonomy? [y/n]: "
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

  wp rewrite structure --hard
}
