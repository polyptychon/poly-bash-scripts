#!/bin/bash
source ./all-copy-remote-uploads-to-local.sh
source ./all-import-remote-to-local-db.sh


function backup-remote-sites-light {
  now="$(date +'%d/%m/%Y')"

  all-copy-remote-uploads-to-local
  all-import-remote-to-local-db
  git add --all
  git commit -m "backup at $now"
}
