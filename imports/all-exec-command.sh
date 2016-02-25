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

COMMAND_="git status"
echo -n "Please type your command (git status):"
read COMMAND_TEMP
if [[ ! -z $COMMAND_TEMP ]]; then
  COMMAND_=$COMMAND_TEMP
fi

echo -n "Please type your command (.):"
read DIR_

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    set -e
    trap 'echo "Could not change directory $DIR_"' INT TERM EXIT
    if [[ ! -z $DIR_ ]] && [[ -d $DIR_ ]]; then
      cd $DIR_
    fi
    trap 'echo "Could not exec command"' INT TERM EXIT
    echo "${bold}${green}$d${reset}${reset_bold}"
    ${COMMAND_}
    trap 'echo "OK"' INT TERM EXIT
    if [[ ! -z $DIR_ ]] && [[ $DIR_!="." ]]; then
      cd ..
    fi
    cd ..
  fi
done

}
