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

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

UP=$(pgrep mysql | wc -l);
if [[ "$UP" -ne 1 ]]; then
  echo "Could not connect to local mysql. Exiting..."
  exit
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "You are about to ${bold}${red}update all sites${reset}${reset_bold}. Are you sure? Y/N "
read answer
if [[ $answer =~ ^[Nn]$ ]]; then
  exit
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
      git add --all $PATH_TO_WORDPRESS
      git commit -m "update wordpress"
      set -e
    fi
    trap 'echo "could not update plugins"; clean_up' INT TERM EXIT
    wp plugin update --all --dry-run
    wp plugin update --all
    if [[ -d .git ]]; then
      set +e
      git add --all $PATH_TO_WORDPRESS/wp-content/plugins
      git add --all $PATH_TO_WORDPRESS/wp-content/languages
      git commit -m "update plugins"
      set -e
    fi
    trap 'echo "could not update themes"; clean_up' INT TERM EXIT
    wp theme update --all --dry-run
    wp theme update --all
    if [[ -d .git ]]; then
      set +e
      git add --all $PATH_TO_WORDPRESS/wp-content/themes
      git add --all $PATH_TO_WORDPRESS/wp-content/languages
      git commit -m "update themes"
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
  elif [[ -d $d/$PATH_TO_DRUPAL ]]; then
    cd "$d"
    LOCAL_DOMAIN=`get_env_value "LOCAL_DOMAIN"`
    echo $LOCAL_DOMAIN
    cd "$PATH_TO_DRUPAL"
    if [[ -d .git ]]; then
      set +e
      git stash --quiet
      git pull --quiet
      set -e
    fi
    set -e
    trap 'echo "could not update wordpress"; clean_up' INT TERM EXIT

    drush vset --exact maintenance_mode 1 drush cache-clear all
    drush pm-update drupal
    drush up
    drush vset --exact maintenance_mode 0 drush cache-clear all

    if [[ -d .git ]]; then
      set +e
      git add --all $PATH_TO_DRUPAL
      git commit -m "update drupal"
      set -e
    fi

    set +e
    if [[ -d .git ]]; then
      git stash pop --quiet
    fi
    echo
    trap 'echo "OK"; clean_up' INT TERM EXIT
    cd ../../
  fi
done

}
