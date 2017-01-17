#!/bin/bash

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
}

function all-deploy-sites {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

if [[ ! -z $1 ]]; then
  ASK_FOR_CONFIRMATION=$1
else
  ASK_FOR_CONFIRMATION="y"
fi

LOCAL_PATHS=()

if [[ -z $REMOTE_PATH ]]; then
  if [[ ! -z $REMOTE_SSH_ROOT_PATH ]]; then
    REMOTE_PATH=$REMOTE_SSH_ROOT_PATH
  else
    echo "REMOTE_PATH variable is not set!"
    exit
  fi
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi

if [[ -z $PATH_TO_DRUPAL ]]; then
  PATH_TO_DRUPAL="drupal_site"
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

if [[ $ASK_FOR_CONFIRMATION =~ ^[Yy]$  ]]; then
  echo -n "You are about to ${bold}${red}deploy all sites${reset}${reset_bold} to host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N "
  read REPLY
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Exiting..."
    exit
  fi
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]] || [[ -d $d/$PATH_TO_DRUPAL ]]; then
    PATH_NAME=$(echo $d | sed -E "s/\///g")
    LOCAL_PATHS+=($PATH_NAME)
  fi
done

ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
  if [[ ! -d $PATH_TO_TEMP_EXPORTS ]]; then
    mkdir $PATH_TO_TEMP_EXPORTS
  fi
  cd $REMOTE_PATH
  for d in ${LOCAL_PATHS[@]}; do
    dl=\$(echo \$d | tr '[:upper:]' '[:lower:]')
    if [[ -d \$d ]] || [[ -d \$dl ]]; then
      if [[ -d \$d ]]; then
        cd \$d
      elif [[ -d \$dl ]]; then
        cd \$dl
      fi

      echo \$d
      git stash clear
      git stash --quiet
      git status
      git pull
      git stash pop --quiet
      echo ""
      cd ..
    fi
  done
  exit
EOF

}
