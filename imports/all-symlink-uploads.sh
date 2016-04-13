#!/bin/bash

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}

function all-symlink-uploads() {

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
  PATH_TO_WORDPRESS=wordpress
fi

if [[ -z $PATH_TO_DRUPAL ]]; then
  PATH_TO_DRUPAL="drupal_site"
fi

if [[ -z $PATH_TO_UPLOADS ]]; then
  PATH_TO_UPLOADS="$PATH_TO_WORDPRESS/wp-content/uploads"
fi

if [[ -z $PATH_TO_WORDPRESS_SITES ]]; then
  PATH_TO_WORDPRESS_SITES="/Volumes/POLYPTYCHON/Work/wordpress-sites"
fi
if [[ -z $PATH_TO_DRUPAL_SITES ]]; then
  PATH_TO_DRUPAL_SITES="/Volumes/POLYPTYCHON/Work/drupal-sites"
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "You are about to ${bold}${red}delete${reset}${reset_bold} local uploads and create symlink for uploads. Are you sure? Y/N "
read answer
if [[ $answer =~ ^[Nn]$ ]]; then
  echo "Exiting..."
  exit
fi

echo -n " # Path to wordpress projects ($PATH_TO_WORDPRESS_SITES): "
read PATH_TO_WORDPRESS_SITES_TEMP
if [ ! -z ${PATH_TO_WORDPRESS_SITES_TEMP} ]; then
  PATH_TO_WORDPRESS_SITES=$PATH_TO_WORDPRESS_SITES_TEMP
fi

echo -n " # Path to drupal projects ($PATH_TO_DRUPAL_SITES): "
read PATH_TO_DRUPAL_SITES_TEMP
if [ ! -z ${PATH_TO_DRUPAL_SITES_TEMP} ]; then
  PATH_TO_DRUPAL_SITES=$PATH_TO_DRUPAL_SITES_TEMP
fi

for d in */ ; do
  PATH_NAME=$(echo $d | sed -E "s/\///g")

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $d/$PATH_TO_WORDPRESS ]; then
    PATH_TO_UPLOADS="$PATH_TO_WORDPRESS/wp-content/uploads"
    PATH_TO_SITES=$PATH_TO_WORDPRESS_SITES
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $d/$PATH_TO_DRUPAL ]; then
    PATH_TO_UPLOADS="$PATH_TO_DRUPAL/sites/default/files"
    PATH_TO_SITES=$PATH_TO_DRUPAL_SITES
  else
    echo "$d is not a wordpress or drupal site"
    continue
  fi
  if [[ ! -d $PATH_TO_SITES/$PATH_NAME/$PATH_TO_UPLOADS ]]; then
    echo "$PATH_TO_SITES/$PATH_NAME/$PATH_TO_UPLOADS is not a valid path"
    continue
  fi
  if [[ -d $d/$PATH_TO_UPLOADS ]]; then
    rm -rf $d/$PATH_TO_UPLOADS
  fi
  if [[ -f $d/$PATH_TO_UPLOADS ]]; then
    rm $d/$PATH_TO_UPLOADS
  fi
  ln -sf $PATH_TO_SITES/$PATH_NAME/$PATH_TO_UPLOADS $PATH_NAME/$PATH_TO_UPLOADS
  echo "${bold}${green}Success${reset}${reset_bold} $PATH_NAME"
done

}
