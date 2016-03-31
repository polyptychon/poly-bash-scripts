#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-open-validate-html() {

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
      open "https://validator.w3.org/nu/?doc=http://$REMOTE_DOMAIN/"
      echo $REMOTE_DOMAIN
    fi
    trap 'echo "OK"' INT TERM EXIT
    cd ..
  fi
done

}
