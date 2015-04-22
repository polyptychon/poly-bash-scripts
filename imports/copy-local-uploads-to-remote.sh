#!/bin/bash

function copy-local-uploads-to-remote {
  set -e
  source .env

  if [ -z $PATH_TO_WORDPRESS ] || [ ! -d $PATH_TO_WORDPRESS ]; then
    echo "Can not find wordpress installation. Exiting..."
    exit;
  fi

  echo -n "You want to replace remote uploads with local. Are you sure? Y/N "
  read answer
  if [[ $answer =~ ^[Yy]$ ]]; then
    scp -rCP $SSH_PORT $PATH_TO_WORDPRESS/wp-content/uploads "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/"
  fi
}
