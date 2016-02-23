#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-exec-command() {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "Host: ${bold}${red}$SSH_HOST${reset}${reset_bold}. Do you want to exec command to all sites? Y/N "
read answer
if [[ $answer =~ ^[Nn]$ ]]; then
  exit
fi

echo -n "Please type your command (Command example: git status):"
read COMMAND_
if [[ -z $COMMAND_ ]]; then
  echo "You did not type a command. Exiting..."
  exit
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    set -e
    trap 'echo "Could not exec command"' INT TERM EXIT
    echo "${bold}${green}$d${reset}${reset_bold}"
    eval $COMMAND_
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
