#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-copy-local-uploads-to-remote() {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi
if [[ -z $PATH_TO_DRUPAL ]]; then
  PATH_TO_DRUPAL="drupal_site"
fi

if [[ -z $REMOTE_PATH ]]; then
  THE_SITES_PATH="~/domains"
else
  THE_SITES_PATH=$REMOTE_PATH
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "You are about to ${bold}${red}replace remote uploads for all sites${reset}${reset_bold} with local to host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N "
read answer
if [[ $answer =~ ^[Nn]$ ]]; then
  exit
fi

if [[ -d ~/.ssh ]]; then
  if [[ ! -d ~/.ssh/ctl ]]; then
    mkdir ~/.ssh/ctl
  fi
  ssh -p $SSH_PORT -nNf -o ControlMaster=yes -o ControlPath="$HOME/.ssh/ctl/%L-%r@%h:%p" $SSH_USERNAME@$SSH_HOST
  USE_CONTROL_MASTER=true
fi

ASK_FOR_CONFIRMATION="n"

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]] || [[ -d $d/$PATH_TO_DRUPAL ]]; then
    cd "$d"
    set -e
    trap 'echo "could not copy remote uploads"' INT TERM EXIT
    if [[ ! -z $SSH_HOST ]] && [[ ! -z $SSH_USERNAME ]] && [[ ! -z $SSH_PORT ]] && [[ ! -z $REMOTE_PATH ]]; then
      PATH_NAME=$(echo $d | sed -E "s/\///g")
      PATH_TO_SITE=$THE_SITES_PATH/$PATH_NAME
      echo "Copying to... ${bold}${red}$PATH_TO_SITE${reset}${reset_bold}"
      copy-local-uploads-to-remote $SSH_HOST $SSH_USERNAME $SSH_PORT $PATH_TO_SITE $PATH_TO_WORDPRESS $PATH_TO_DRUPAL $USE_CONTROL_MASTER $ASK_FOR_CONFIRMATION
      echo "${bold}${green}Success${reset}${reset_bold}"
    else
      copy-local-uploads-to-remote
    fi
    echo
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
