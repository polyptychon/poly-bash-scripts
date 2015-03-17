#!/bin/bash
if [ -f .env ]; then
  source .env
elif [[ -f ../.env ]]; then
  source ../.env
fi

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

git checkout --orphan gh-pages
cp -Rf ./static/builds/production/. ./
git rm -rf wordpress
git rm -rf static
git rm -rf exports
git rm -f .gitignore
git rm -f .env
git rm -f README.md
git rm -f wp-cli.local.yml

echo ".idea" > .gitignore
echo "static" >> .gitignore
echo "wordpress" >> .gitignore
echo "exports" >> .gitignore
echo ".env" >> .gitignore
echo "README.md" >> .gitignore
echo "wp-cli.local.yml" >> .gitignore

git add --all
git commit -m 'update gh-pages'
git push --set-upstream origin gh-pages

trap 'git stash pop' INT TERM EXIT
git checkout master
git stash pop
