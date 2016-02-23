#!/bin/bash

function clean_up {
  ssh -O exit -o ControlPath="$HOME/.ssh/ctl/%L-%r@%h:%p" user@host
}

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-copy-remote-uploads-to-local() {

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

echo -n "You are about to ${bold}${red}copy remote${reset}${reset_bold} uploads to ${bold}${red}local${reset}${reset_bold} from host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N "
read answer
if [[ $answer =~ ^[Nn]$ ]]; then
  exit
fi

if [[ -d ~/.ssh ]]; then
  if [[ ! -d ~/.ssh/ctl ]]; then
    mkdir ~/.ssh/ctl
  fi
  ssh -p $SSH_PORT -nNf -o ControlMaster=yes -o ControlPath="$HOME/.ssh/ctl/%L-%r@%h:%p" $SSH_USERNAME@$SSH_HOST
fi
for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    set -e
    trap 'echo "could not copy remote uploads; clean_up"' INT TERM EXIT
    if [[ ! -z $SSH_HOST ]] && [[ ! -z $SSH_USERNAME ]] && [[ ! -z $SSH_PORT ]] && [[ ! -z $REMOTE_PATH ]] && [[ ! -z $PATH_TO_WORDPRESS ]]; then
      PATH_NAME=$(echo $d | sed -E "s/\///g")
      PATH_TO_SITE=$THE_SITES_PATH/$PATH_NAME
      echo "Copying to... ${bold}${red}$PATH_TO_SITE${reset}${reset_bold}"
      copy-remote-uploads-to-local $SSH_HOST $SSH_USERNAME $SSH_PORT $PATH_TO_SITE $PATH_TO_WORDPRESS true
      echo "${bold}${green}Success${reset}${reset_bold}"
    else
      copy-remote-uploads-to-local
    fi
    echo
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done
clean_up
}
