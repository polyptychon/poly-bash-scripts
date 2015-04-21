#!/bin/bash

function backup-all-remote-sites {
  set -e

  source .env
  sites=()

  # Read the file in parameter and fill the array named "array"
  getArray() {
      i=0
      while read line # Read a line
      do
          sites[i]=$line # Put it into the array
          i=$(($i + 1))
      done < $1
  }

  getArray "sites.txt"

  for e in "${sites[@]}"
  do
    if [ ! -d $e ]; then
      mkdir $e
    fi
    REMOTE_PATH=$REMOTE_SSH_ROOT_PATH/$e

    if ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/$PATH_TO_WORDPRESS ]; then # if is a wordpress site
      if [ ! -d $e/$PATH_TO_WORDPRESS ]; then
        mkdir $e/$PATH_TO_WORDPRESS
        mkdir $e/$PATH_TO_WORDPRESS/wp-content/
      fi
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $e/$PATH_TO_WORDPRESS/wp-content/uploads
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-config.php" $e/$PATH_TO_WORDPRESS/wp-config.php
    elif ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/$PATH_TO_DRUPAL ]; then # if is a drupal site
      if [ ! -d $e/$PATH_TO_DRUPAL ]; then
        mkdir $e/$PATH_TO_DRUPAL
        mkdir $e/$PATH_TO_DRUPAL/sites
      fi
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default" $e/$PATH_TO_DRUPAL/sites/default
    fi
    if ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/.env ]; then
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/.env" $e/.env
    fi

  done
}
