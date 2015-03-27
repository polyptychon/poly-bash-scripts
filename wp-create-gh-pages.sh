#!/bin/bash
if [ -f .env ]; then
  source .env
elif [[ -f ../.env ]]; then
  source ../.env
fi

function restore_master() {
  git checkout master
  set +e
  rm -r assets
  set -e
  git stash pop
}

set -e
DIR_NAME=${PWD##*/}

if [[ $DIR_NAME != 'static' ]] && [[ `ls -A ./static` ]]; then
  cd ./static
elif [[ $DIR_NAME == 'static' ]]; then
  cd .
else
  exit
fi
DIR_NAME=${PWD##*/}

gulp production

if [[ $DIR_NAME == 'static' ]]; then
  cd ..
fi

set +e
git stash
set -e

trap 'restore_master' INT TERM EXIT

if [[ `git branch | grep -Fo gh-pages`=='gh-pages' ]]; then
  git checkout gh-pages
  cp -Rf ./static/builds/production/. ./
else
  git checkout --orphan gh-pages
  cp -Rf ./static/builds/production/. ./
  git rm -rf $PATH_TO_WORDPRESS
  git rm -rf static
  git rm -rf $PATH_TO_EXPORTS
  git rm -f .gitignore
  git rm -f .env
  git rm -f README.md
  git rm -f wp-cli.local.ymlß
fi

if [[ ! -f .gitignore ]]; then
  echo ".idea" > .gitignore
  echo "static" >> .gitignore
  echo "$PATH_TO_WORDPRESS" >> .gitignore
  echo "$PATH_TO_EXPORTS" >> .gitignore
  echo ".env" >> .gitignore
  echo "README.md" >> .gitignore
  echo "wp-cli.local.yml" >> .gitignore
fi

git add --all
git commit -m 'update gh-pages'

git push --set-upstream origin gh-pages

restore_master
