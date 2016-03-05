#!/bin/bash

function copy-local-uploads-to-remote {
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
  if [[ ! -z $7 ]]; then
    ASK_FOR_CONFIRMATION=$7
  else
    ASK_FOR_CONFIRMATION="y"
  fi

  bold=`tput bold`
  red=`tput setaf 1`
  green=`tput setaf 2`
  reset=`tput sgr0`
  reset_bold=`tput rmso`

  rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
  if [[ $rsync_version != '3.1.0' ]]; then
    echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
  fi

  if [[ $ASK_FOR_CONFIRMATION =~ ^[Yy]$  ]]; then
    echo -n "You want to replace remote uploads with local for host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N "
    read answer
    if [[ $answer =~ ^[Nn]$ ]]; then
      exit
    fi
  fi

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    PATH_TO_UPLOADS="$PATH_TO_WORDPRESS/wp-content/uploads"
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    PATH_TO_UPLOADS="$PATH_TO_DRUPAL/sites/default/files"
  else
    echo "Could not find path! Exiting..."
    exit
  fi
  CONTROL_PATH=""
  if [[ $USE_CONTROLMASTER == true ]]; then
    CONTROL_PATH="-o 'ControlPath=$HOME/.ssh/ctl/%L-%r@%h:%p'"
  fi
  # --dry-run
  rsync --iconv=UTF-8-MAC,UTF-8 -avz -e "ssh -p $SSH_PORT $CONTROL_PATH" --progress $PATH_TO_UPLOADS/* $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_UPLOADS
  # scp -rCP $SSH_PORT $PATH_TO_UPLOADS/* "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/$PATH_TO_UPLOADS"
}
