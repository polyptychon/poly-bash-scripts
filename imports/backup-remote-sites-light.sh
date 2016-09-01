#!/bin/bash

function backup-remote-sites-light {
  now="$(date +'%d/%m/%Y')"
  set +e
  all-copy-remote-uploads-to-local "n"
  all-import-remote-to-local-db "n"
  git add --all
  git commit -m "backup at $now"
  set -e
}
