#!/bin/bash

function deploy-stage {
set -e

# load variables
source .env

DIR_NAME=${PWD##*/}

ssh -t -p 2222 xarisd@polyptychon.gr bash -c "'

if [[ -d $REMOTE_PATH ]]; then

  cd $REMOTE_PATH
  git stash --quiet
  git status
  git pull
  git stash pop --quiet
  exit

else

  cd $REMOTE_SSH_ROOT_PATH
  pwd
  git clone git@github.com:polyptychon/$DIR_NAME.git

fi

'"

}
