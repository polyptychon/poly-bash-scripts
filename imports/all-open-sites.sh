#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-open-sites() {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

while (true); do
  echo -n "Open local or remote sites? L/R "
  read answer
  if [[ $answer =~ ^[Ll]$ ]]; then
    OPEN_LOCAL=true
    break
  elif [[ $answer =~ ^[Ll]$ ]]; then
    OPEN_LOCAL=false
    break
  fi
done

ADMIN_PATH=""
echo -n "Open sites in admin? Y/N "
read answer
if [[ $answer =~ ^[Yy]$ ]]; then
  ADMIN_PATH="wp-admin"
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    set -e
    trap 'echo "could not open chrome"' INT TERM EXIT
    if [[ $OPEN_LOCAL ]]; then
      trap 'echo "could not read .env variable LOCAL_DOMAIN"' INT TERM EXIT
      LOCAL_DOMAIN=`get_env_value "LOCAL_DOMAIN"`
      open "http://$LOCAL_DOMAIN/$ADMIN_PATH"
      echo $LOCAL_DOMAIN
    else
      trap 'echo "could not read .env variable REMOTE_DOMAIN"' INT TERM EXIT
      REMOTE_DOMAIN=`get_env_value "REMOTE_DOMAIN"`
      open "http://$REMOTE_DOMAIN/$ADMIN_PATH"
      echo $REMOTE_DOMAIN
    fi
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
