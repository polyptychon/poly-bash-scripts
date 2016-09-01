#!/bin/bash

function backup-remote-sites-light {
  now="$(date +'%d/%m/%Y')"
  set +e
  all-copy-remote-uploads-to-local "y"
  all-import-remote-to-local-db
  git add --all
  git commit -m "backup at $now"
  set -e
}
