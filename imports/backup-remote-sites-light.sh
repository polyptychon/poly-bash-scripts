#!/bin/bash

function backup-remote-sites-light {
  now="$(date +'%d/%m/%Y')"
  set +e
  all-dump-remote-db
  all-copy-remote-uploads-to-local "n"
  git add --all
  git commit -m "backup at $now"
  set -e
}
