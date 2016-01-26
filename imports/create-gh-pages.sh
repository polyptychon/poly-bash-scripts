#!/bin/bash

function create-gh-pages {
  if [[ -f .env ]]; then
    source .env
  elif [[ -f ../.env ]]; then
    source ../.env
  fi

  if [ ! -d ./static/node_modules ] && [ ! -d ./node_modules ]; then
    echo "Please run 'npm install' first. Exiting..."
    exit;
  fi

  function restore_master() {
    set +e
    git checkout master
    if [ -d assets ]; then
      rm -r assets
    fi
    git stash pop
    set -e
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

  trap 'echo "an error occurred"; restore_master' INT TERM EXIT

  if [[ `git branch | grep -Fo gh-pages` == 'gh-pages' ]]; then
    git checkout gh-pages
    cp -Rf ./static/builds/production/. ./
  else
    git checkout --orphan gh-pages
    cp -Rf ./static/builds/production/. ./
    set +e
    git rm -rf $PATH_TO_WORDPRESS
    git rm -rf static
    git rm -rf $PATH_TO_EXPORTS
    git rm -f .gitignore
    git rm -f .env
    git rm -f README.md
    git rm -f admin-password.txt
    git rm -f wp-cli.local.yml
    set -e
  fi

  if [[ ! -f .gitignore ]]; then
    echo ".idea" > .gitignore
    echo ".DS_Store" >> .gitignore
    echo "static" >> .gitignore
    echo "$PATH_TO_WORDPRESS" >> .gitignore
    echo "$PATH_TO_EXPORTS" >> .gitignore
    echo ".env" >> .gitignore
    echo "README.md" >> .gitignore
    echo "admin-password.txt" >> .gitignore
    echo "wp-cli.local.yml" >> .gitignore
  fi

  trap 'echo "nothing to commit, working directory clean"; restore_master' INT TERM EXIT
  set +e
  git status
  git add --all
  git commit -m 'update gh-pages'
  git push --set-upstream origin gh-pages
  set -e

  restore_master
}
