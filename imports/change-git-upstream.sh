#!/bin/bash

function git-upstream {
set -e

# load variables
if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
fi

function clean_up
{
  set +e
  git stash pop --quiet
  set -e
}

# perform clean up on error
trap 'echo "Clean up..."; clean_up' INT TERM EXIT

set +e
git stash --quiet
set -e

OLD_GIT_REMOTE_ORIGIN_URL=$(git config --get remote.origin.url)
echo -n "New remote origin URL? ($OLD_GIT_REMOTE_ORIGIN_URL): "
read GIT_REMOTE_ORIGIN_URL_TEMP

if [ ! -z $GIT_REMOTE_ORIGIN_URL_TEMP ]; then
  GIT_REMOTE_ORIGIN_URL=$GIT_REMOTE_ORIGIN_URL_TEMP
elif [ -z $GIT_REMOTE_ORIGIN_URL_TEMP ] || [ $GIT_REMOTE_ORIGIN_URL == $OLD_GIT_REMOTE_ORIGIN_URL ]; then
  echo "You did not change remote origin. Aborting..."
  clean_up
  exit
fi

echo -n "You will change git remote origin url. Are you sure? Y/N: "
read REPLY
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborting..."
  clean_up
  exit
fi

git remote rm origin
git remote add origin $GIT_REMOTE_ORIGIN_URL
git remote -v # Check new remote origin
set +e
git push --set-upstream-to origin/master
set -e

ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
  cd $REMOTE_PATH
  git remote rm origin
  git remote add origin $GIT_REMOTE_ORIGIN_URL
  git remote -v
  git fetch
  git branch --set-upstream-to origin/master
  exit
'"

echo "$(sed '/GIT_REMOTE_ORIGIN_URL/d' .env)" > .env
echo "GIT_REMOTE_ORIGIN_URL=$GIT_REMOTE_ORIGIN_URL" >> .env
git add .env
git commit -m "change GIT_REMOTE_ORIGIN_URL"
# perform clean up
clean_up

}

