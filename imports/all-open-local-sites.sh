#!/bin/bash
if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-open-local-sites() {

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    set -e
    trap 'echo "could not read .env variable LOCAL_DOMAIN"' INT TERM EXIT
    LOCAL_DOMAIN=`get_env_value "LOCAL_DOMAIN"`
    trap 'echo "could not open chrome"' INT TERM EXIT
    open "http://$LOCAL_DOMAIN/"
    echo $LOCAL_DOMAIN
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
