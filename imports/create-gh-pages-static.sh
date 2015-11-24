#!/bin/bash

function create-gh-pages {
  if [[ -f .env ]]; then
    source .env
  fi

  if [ ! -d node_modules ] && [ ! -d node_modules ]; then
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

  gulp production

  set +e
  git stash
  set -e

  trap 'echo "an error occurred"; restore_master' INT TERM EXIT

  if [[ `git branch | grep -Fo gh-pages` == 'gh-pages' ]]; then
    git checkout gh-pages
    cp -Rf ./builds/production/. ./
  else
    git checkout --orphan gh-pages
    cp -Rf ./builds/production/. ./
    set +e
    git rm -rf _mockups
    git rm -rf _src
    git rm -rf builds
    git rm -f node_modules
    git rm -f .env
    git rm -f gulpfile.js
    git rm -f package.json
    set -e
  fi

  if [[ ! -f .gitignore ]]; then
    echo ".idea" > .gitignore
    echo ".DS_Store" >> .gitignore
    echo "_mockups" >> .gitignore
    echo "_src" >> .gitignore
    echo "builds" >> .gitignore
    echo "node_modules" >> .gitignore
    echo ".env" >> .gitignore
    echo "gulpfile.js" >> .gitignore
    echo "package.json" >> .gitignore
    echo "README.md" >> .gitignore
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
