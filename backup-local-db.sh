#!/bin/bash
set -e

# load variables
source .env

function clean_up
{
  rm -rf $PATH_TO_EXPORTS/temp.sql
  git stash pop --quiet
}

# perform clean up on error
trap 'echo "Removing temp files..."; clean_up' INT TERM EXIT

set +e
git stash
set -e

# export local db to sql dump file
wp db export $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS --skip-comments --skip-dump-date --skip-opt --add-drop-table

# clean up local sql dump file for less commits
sed -e '/-- Dump completed on/d;/-- MySQL dump/d;/-- Host\: /d;/-- Server version/d' $PATH_TO_EXPORTS/temp.sql > $PATH_TO_EXPORTS/local.sql

# commit changes
git add $PATH_TO_EXPORTS/local.sql
git commit -m "backup local db"

# perform clean up
clean_up
