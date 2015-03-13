#!/bin/bash
set -e
source .env

set +e
git stash
set -e

# backup remote db
ssh -p 2222 xarisd@polyptychon.gr bash -c "'
cd $REMOTE_PATH
wp db export exports/temp.sql --path=./wordpress
exit
'"
scp -CP 2222 $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/exports/temp.sql ./exports/
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' exports/temp.sql > ./exports/remote.sql

set +e
git add exports/.
git commit -m "backup remote db"
git stash pop
set -e
