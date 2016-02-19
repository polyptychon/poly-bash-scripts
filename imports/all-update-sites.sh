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

function all-update-sites() {

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    LOCAL_DOMAIN=`get_env_value "LOCAL_DOMAIN"`
    echo $LOCAL_DOMAIN
    if [[ -d .git ]]; then
      set +e
      git stash --quiet
      git pull --quiet
      set -e
    fi
    set -e
    trap 'echo "could not update wordpress"; clean_up' INT TERM EXIT
    wp core update
    if [[ -d .git ]]; then
      set +e
      git add $PATH_TO_WORDPRESS/wp-admin
      git add $PATH_TO_WORDPRESS/wp-includes
      git commit -m "update wordpress"
      set -e
    fi
    trap 'echo "could not update plugins"; clean_up' INT TERM EXIT
    wp plugin update --all
    if [[ -d .git ]]; then
      set +e
      git add $PATH_TO_WORDPRESS/wp-content/plugins
      git commit -m "update plugins"
      set -e
    fi
    trap 'echo "could not open chrome"; clean_up' INT TERM EXIT
    open "http://"$LOCAL_DOMAIN/wp-admin/update-core.php
    set +e
    if [[ -d .git ]]; then
      git stash pop --quiet
    fi
    echo
    trap 'echo "OK"; clean_up' INT TERM EXIT
    cd ..
  fi
done

}
