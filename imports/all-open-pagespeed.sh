#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-open-pagespeed() {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

for d in */ ; do
  if [[ -f $d/.env ]]; then
    cd "$d"
    set -e

    trap 'echo "could not read .env variable REMOTE_DOMAIN"' INT TERM EXIT
    REMOTE_DOMAIN=`get_env_value "REMOTE_DOMAIN"`
    if [[ ! -z $REMOTE_DOMAIN ]]; then
      trap 'echo "could not open chrome"' INT TERM EXIT
      open "https://developers.google.com/speed/pagespeed/insights/?url=http://$REMOTE_DOMAIN/&tab=desktop"
      echo $REMOTE_DOMAIN
    fi

    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
