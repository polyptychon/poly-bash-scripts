#!/bin/bash

function deploy-stage {
set -e

# load variables
source .env

ssh -t -p 2222 xarisd@polyptychon.gr bash -c "'

cd $REMOTE_PATH
git status
git pull
exit

'"

}
