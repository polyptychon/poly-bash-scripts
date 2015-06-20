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
    rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
    if [[ $rsync_version != '3.1.0' ]]; then
      echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
    fi
    rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_WORDPRESS/wp-content/uploads $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/
    # scp -rCP $SSH_PORT $PATH_TO_WORDPRESS/wp-content/uploads "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/"
  fi
}
