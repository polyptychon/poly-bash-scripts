#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}
function clean_up() {
  if [[ -d .git ]]; then
    set +e
    git stash pop --quiet
    cd ..
    set -e
  fi
}

function all-deploy-sites() {

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

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "You are about to ${bold}${red}deploy all sites${reset}${reset_bold} to host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N "
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
    trap 'echo "could not read .env"; clean_up' INT TERM EXIT

    REMOTE_PATH=`get_env_value "REMOTE_PATH"`
    REMOTE_PATH_LOWER=$(echo $REMOTE_PATH | tr '[:upper:]' '[:lower:]')
    echo ${bold}${green}$REMOTE_PATH${reset}${reset_bold}

    set +e
    git stash --quiet
    git pull --quiet
    set -e

    set -e
    trap 'echo "could not push"; clean_up' INT TERM EXIT
    git push

    set +e
    LOCAL_COMMIT_HASH=$(git rev-parse HEAD)
    ssh -t -p $SSH_PORT -o 'ControlPath=$HOME/.ssh/ctl/%L-%r@%h:%p' $SSH_USERNAME@$SSH_HOST bash -c "'
      if [[ -d $REMOTE_PATH ]] || [[ -d $REMOTE_PATH_LOWER ]]; then
        if [[ -d $REMOTE_PATH ]]; then
          cd $REMOTE_PATH
        elif [[ -d $REMOTE_PATH_LOWER ]]; then
          cd $REMOTE_PATH_LOWER
        fi

        REMOTE_COMMIT_HASH=\$(git rev-parse HEAD)
        if [ $LOCAL_COMMIT_HASH == \$REMOTE_COMMIT_HASH ]; then
          echo \"Everything is up to date. No action is required\"
          exit
        else
          git stash clear
          git stash --quiet
          git status
          git pull
          git stash pop --quiet
          exit
        fi
      else
        echo \"Could not find path $REMOTE_PATH in remote server\"
      fi
    '"
    set +e
    git stash pop --quiet
    set -e
    echo
    trap 'echo "OK"; clean_up' INT TERM EXIT
    cd ..
  fi
done

}
