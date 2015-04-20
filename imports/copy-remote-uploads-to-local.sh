#!/bin/bash
function copy-remote-uploads-to-local {
  set -e
  source .env

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $PATH_TO_WORDPRESS/wp-content/
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files" $PATH_TO_DRUPAL/sites/default/
  else
    echo "Can not find CMS installation. Exiting..."
    exit;
  fi
}
