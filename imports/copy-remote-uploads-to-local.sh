#!/bin/bash
function copy-remote-uploads-to-local {
  set -e
  if [[ -f .env ]]; then
    source .env
    if [[ -f .env_override ]]; then
      source .env_override
    fi
  fi
  if [[ ! -z $1 ]]; then
    SSH_HOST=$1
  fi
  if [[ ! -z $2 ]]; then
    SSH_USERNAME=$2
  fi
  if [[ ! -z $3 ]]; then
    SSH_PORT=$3
  fi
  if [[ ! -z $4 ]]; then
    REMOTE_PATH=$4
  fi
  if [[ ! -z $5 ]]; then
    PATH_TO_WORDPRESS=$5
  fi
  if [[ ! -z $6 ]]; then
    USE_CONTROLMASTER=$6
  else
    USE_CONTROLMASTER=false
  fi
  rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
  if [[ $rsync_version != '3.1.0' ]]; then
    echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
  fi
  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    if [[ $USE_CONTROLMASTER ]]; then
      rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT -o 'ControlPath=$HOME/.ssh/ctl/%L-%r@%h:%p'" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads/* $PATH_TO_WORDPRESS/wp-content/uploads
    else
      rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads/* $PATH_TO_WORDPRESS/wp-content/uploads
    fi
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    if [[ $USE_CONTROLMASTER ]]; then
      rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT -o 'ControlPath=$HOME/.ssh/ctl/%L-%r@%h:%p'" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files/* $PATH_TO_DRUPAL/sites/default/files
    else
      rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files/* $PATH_TO_DRUPAL/sites/default/files
    fi
    # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/files" $PATH_TO_DRUPAL/sites/default/
  else
    echo "Can not find CMS installation. Exiting..."
    exit;
  fi
}
