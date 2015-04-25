#!/bin/bash
function copy-remote-uploads-to-local {
  set -e
  source .env

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads $PATH_TO_WORDPRESS/wp-content/
    # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $PATH_TO_WORDPRESS/wp-content/
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files $PATH_TO_DRUPAL/sites/default/
    # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files" $PATH_TO_DRUPAL/sites/default/
  else
    echo "Can not find CMS installation. Exiting..."
    exit;
  fi
}
