#!/bin/bash
function copy-remote-uploads-to-local {
  set -e
  source .env
  rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
  if [[ $rsync_version != '3.1.0' ]]; then
    echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
  fi
  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads $PATH_TO_WORDPRESS/wp-content/
    # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $PATH_TO_WORDPRESS/wp-content/
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files $PATH_TO_DRUPAL/sites/default/
    # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files" $PATH_TO_DRUPAL/sites/default/
  else
    echo "Can not find CMS installation. Exiting..."
    exit;
  fi
}
