#!/bin/bash

function deploy-stage {
set -e

# load variables
if [ -f .env ]; then
  source .env
else
  echo ".env file does not exist. Exiting..."
  exit
fi

DIR_NAME=${PWD##*/}

ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'

if [[ -d $REMOTE_PATH ]]; then

  cd $REMOTE_PATH
  git stash --quiet
  git status
  git pull
  git stash pop --quiet
  exit

else

  cd $REMOTE_SSH_ROOT_PATH
  git clone git@github.com:polyptychon/$DIR_NAME.git

fi

'"

}
