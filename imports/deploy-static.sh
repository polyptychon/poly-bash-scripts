#!/bin/bash

function deploy-static {
  set -e
  if [[ -f .env ]]; then
    source .env
    if [[ -f .env_override ]]; then
      source .env_override
    fi
  fi

  if [ -z $PATH_TO_STATIC_BUILD ] || [ ! -d $PATH_TO_STATIC_BUILD ]; then
    echo "Can not find static folder."
    echo "You must define variable PATH_TO_STATIC_BUILD to .env file."
    echo "Exiting..."
    exit;
  fi
  if [ -z $REMOTE_PATH ]; then
    echo "You must define variable REMOTE_PATH to .env file."
    echo "Exiting..."
    exit;
  fi
  if [[ -f gulpfile.js ]] && [[ -f package.json ]]; then
    echo -n "Do you want to build static files? Y/N "
    read answer_static
    if [[ $answer_static =~ ^[Yy]$ ]]; then
      gulp production
    fi
  fi
  echo -n "You want to sync remote files with local. Are you sure? Y/N "
  read answer
  if [[ $answer =~ ^[Yy]$ ]]; then
    find $PATH_TO_STATIC_BUILD -type d -print -exec chmod 755 {} \;
    find $PATH_TO_STATIC_BUILD -type f -print -exec chmod 644 {} \;
    rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
    if [[ $rsync_version != '3.1.0' ]]; then
      echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
    fi
    rsync --iconv=UTF-8-MAC,UTF-8 --exclude .DS_STORE -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_STATIC_BUILD/ $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/
  fi
}
