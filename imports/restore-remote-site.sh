function restore-remote-site {
  set -e

  if [ -f .env ]; then
    source .env
  fi

  RESTORE_REPOSITORY=1
  RESTORE_UPLOADS=1
  RESTORE_CONFIG=1
  RESTORE_DB=1

  if [ $RESTORE_REPOSITORY == 1 ]; then
    restore-remote-repository
  fi

  if [ $RESTORE_UPLOADS == 1 ]; then
    restore-remote-uploads
  fi

  if [ $RESTORE_CONFIG == 1 ]; then
    restore-remote-config
  fi

  if [ $RESTORE_DB == 1 ]; then
    restore-remote-db
  fi

}