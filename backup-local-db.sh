#!/bin/bash
set -e
source .env
# expect -c "
# spawn mysqldump -p -u $LOCAL_DATABASE_USERNAME $LOCAL_DATABASE
# expect -nocase \"password:\" {send \"$LOCAL_DATABASE_PASSWORD\r\"; interact}
# " > exports/temp.sql
set +e
git stash
set -e

wp db export exports/temp.sql --path=./wordpress
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' exports/temp.sql > ./exports/local.sql

set +e
git add exports/.
git commit -m "backup local db"
git push
git stash pop
set -e
