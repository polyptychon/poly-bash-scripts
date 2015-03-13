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

wp db export exports/temp.sql --path=$PATH_TO_WORDPRESS
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.sql

set +e
git add $PATH_TO_EXPORTS/.
git commit -m "backup local db"
git stash pop
set -e
