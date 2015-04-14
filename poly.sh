#!/bin/bash
# set -e

source ~/wp_scripts/imports/add-custom-post-types.sh
source ~/wp_scripts/imports/add-taxonomies.sh
source ~/wp_scripts/imports/backup-local-db.sh
source ~/wp_scripts/imports/backup-remote-db.sh
source ~/wp_scripts/imports/copy-local-uploads-to-remote.sh
source ~/wp_scripts/imports/copy-remote-uploads-to-local.sh
source ~/wp_scripts/imports/copy-static-assets-to-wordpress.sh
source ~/wp_scripts/imports/copy-static-fonts-to-wordpress.sh
source ~/wp_scripts/imports/copy-static-images-to-wordpress.sh
source ~/wp_scripts/imports/copy-static-scripts-to-wordpress.sh
source ~/wp_scripts/imports/copy-static-styles-to-wordpress.sh
source ~/wp_scripts/imports/create-gh-pages.sh
source ~/wp_scripts/imports/import-local-to-remote-db.sh
source ~/wp_scripts/imports/import-remote-to-local-db.sh

function init {
  echo "init"
}

#IMPORT
function import {
  options=("local-database-to-remote" "remote-database-to-local")
  exec_arguments options[@]
}
function local-database-to-remote {
  echo "local-database-to-remote"
  import-local-to-remote-db
}
function remote-database-to-local {
  echo "remote-database-to-local"
  import-remote-to-local-db
}

#BACKUP
function backup {
  options=("local-database" "remote-database")
  exec_arguments options[@]
}
function local-database {
  echo "local-database"
  backup-local-db
}
function remote-database {
  echo "remote-database"
  backup-remote-db
}

#COPY
function copy {
  options=("local" "remote" "static")
  exec_arguments options[@]
}
function remote {
  options=("uploads-to-local")
  exec_arguments options[@]
}
#COPY -> REMOTE
function uploads-to-local {
  echo "uploads-to-local"
  copy-remote-uploads-to-local
}
function local {
  options=("uploads-to-remote")
  exec_arguments options[@]
}
#COPY -> LOCAL
function uploads-to-remote {
  echo "uploads-to-remote"
  copy-local-uploads-to-remote
}
function static {
  options=("assets" "styles" "scripts" "fonts" "images")
  exec_arguments options[@]
}
#COPY -> STATIC
function assets {
  echo "assets"
  copy-static-assets-to-wordpress
}
function styles {
  echo "styles"
  copy-static-styles-to-wordpress
}
function scripts {
  echo "scripts"
  copy-static-scripts-to-wordpress
}
function fonts {
  echo "fonts"
  copy-static-fonts-to-wordpress
}
function images {
  echo "images"
  copy-static-images-to-wordpress
}

#CREATE
function create {
  options=("gh-pages")
  exec_arguments options[@]
}
function gh-pages {
  echo "gh-pages"
  create-gh-pages
}

#ADD
function add {
  options=("custom-post-types" "taxonomies")
  exec_arguments options[@]
}
function custom-post-types {
  echo "custom-post-types"
  add-custom-post-types
}
function taxonomies {
  echo "taxonomies"
  add-taxonomies
}

#DEPLOY
function deploy {
  options=("stage" "production")
  exec_arguments options[@]
}
function stage {
  echo "not yet implemented stage deploy"
}
function production {
  echo "not yet implemented production deploy"
}

function main {
  options=("init" "import" "backup" "copy" "create" "add" "deploy")
  exec_arguments options[@]
}

function exec_arguments {
  declare -a options=("${!1}")
  argument=${arguments[0]}

  if [ -z $argument ]; then
    select option in ${options[@]}
    do
      argument=$option
      break
    done
  fi

  containsElement "$argument" "${options[@]}"
  if [[ $? == 1 ]]; then
    arguments=("${arguments[@]:1}")
    exec_arguments options[@]
    return
  fi

  for option in ${options[@]}
  do
    if [[  $option == $argument ]]; then
      arguments=("${arguments[@]:1}")
      eval "$option"
      break
    fi
  done
}
function containsElement () { for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done; return 1; }

arguments=("$@")
main
