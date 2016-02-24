#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-npm-install() {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "Host: ${bold}${red}$SSH_HOST${reset}${reset_bold}. Do you want to exec ${bold}${red}npm install${reset}${reset_bold} to all sites? Y/N "
read answer
if [[ $answer =~ ^[Nn]$ ]]; then
  exit
fi

for d in */ ; do
  if [[ -d $d/.env ]]; then
    cd "$d"
    set -e
    trap 'echo "Could not exec command npm install"' INT TERM EXIT
    if [[ -f static/package.json ]]; then
      echo "${bold}${green}$d${reset}${reset_bold}"
      cd static
      npm install
      cd ..
    elif [[ -f package.json ]]; then
      echo "${bold}${green}$d${reset}${reset_bold}"
      npm install
    else
      echo "${bold}${red}$d${reset}${reset_bold}. Could not find package.json."
    fi
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
