#!/bin/bash
# set -e

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
}
function remote-database-to-local {
  echo "remote-database-to-local"
}

#BACKUP
function backup {
  options=("local-database" "remote-database")
  exec_arguments options[@]
}
function local-database {
  echo "local-database"
}
function remote-database {
  echo "remote-database"
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
}
function local {
  options=("uploads-to-remote")
  exec_arguments options[@]
}
#COPY -> LOCAL
function uploads-to-remote {
  echo "uploads-to-remote"
}
function static {
  options=("assets" "styles" "scripts")
  exec_arguments options[@]
}
#COPY -> STATIC
function assets {
  echo "assets"
}
function styles {
  echo "styles"
}
function scripts {
  echo "scripts"
}

#CREATE
function create {
  options=("gh-pages")
  exec_arguments options[@]
}
function gh-pages {
  echo "gh-pages"
}

#ADD
function add {
  options=("custom-post-types" "taxonomies")
  exec_arguments options[@]
}
function custom-post-types {
  echo "custom-post-types"
}
function taxonomies {
  echo "taxonomies"
}

#DEPLOY
function deploy {
  options=("stage" "production")
  exec_arguments options[@]
}
function stage {
  echo "stage"
}
function production {
  echo "production"
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
