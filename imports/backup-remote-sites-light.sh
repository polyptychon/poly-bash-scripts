#!/bin/bash

function backup-remote-sites-light {
  if [ ! -z $2 ] && [ -d "$1 $2" ]; then
    echo $1 $2
    cd "$1 $2"
  elif [ ! -z $1 ] && [ -d $1 ]; then
    echo $1
    cd $1
  fi

  now="$(date +'%d/%m/%Y')"
  set +e
  all-dump-remote-db "n"
  all-copy-remote-uploads-to-local "n"
  git add --all
  git commit -m "backup at $now"
  set -e
}
