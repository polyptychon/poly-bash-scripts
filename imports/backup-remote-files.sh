#!/bin/bash

function backup-remote-files {
  if [ ! -z $2 ] && [ -d "$1 $2" ]; then
    echo $1 $2
    cd "$1 $2"
  elif [ ! -z $1 ] && [ -d $1 ]; then
    echo $1
    cd $1
  fi
  export PATH="~/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"; 
  set +e
  all-copy-remote-uploads-to-local "n"
  set -e
}
