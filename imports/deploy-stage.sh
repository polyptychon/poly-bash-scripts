#!/bin/bash

function deploy-stage {
set -e

# load variables
if [ -f .env ]; then
  source .env
else
  echo ".env file does not exist. Exiting..."
  exit
fi

DIR_NAME=${PWD##*/}
LOCAL_COMMIT_HASH=$(git rev-parse HEAD)
if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
  IS_WORDPRESS=1
else
  IS_WORDPRESS=0
fi

ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'

if [[ -d $REMOTE_PATH ]]; then

  cd $REMOTE_PATH
  REMOTE_COMMIT_HASH=\$(git rev-parse HEAD)

  if [ $LOCAL_COMMIT_HASH == \$REMOTE_COMMIT_HASH ]; then
    echo \"Everything is up to date. No action is required\"
    exit
  else
    echo \"Remember to git push your local changes first!\"
    git stash --quiet
    git status
    git pull
    git stash pop --quiet
    exit
  fi

else
  if [ $IS_WORDPRESS==1 ]; then
    cd $REMOTE_SSH_ROOT_PATH

    while (true); do
      echo -n \" Remote Database name (xarisd_$DIR_NAME): \"
      read DB_NAME_TEMP
      if [ ! -z \${DB_NAME_TEMP} ]; then
        DB_NAME=\$DB_NAME_TEMP
      else
        DB_NAME=xarisd_$DIR_NAME
      fi

      echo -n \" Remote Database user (xarisd_$DIR_NAME): \"
      read DB_USER_TEMP
      if [ ! -z \${DB_USER_TEMP} ]; then
        DB_USER=\$DB_USER_TEMP
      else
        DB_USER=xarisd_$DIR_NAME
      fi

      echo -n \" Remote Database password: \"
      read DB_PASSWORD_TEMP
      if [ ! -z \${DB_PASSWORD_TEMP} ]; then
        DB_PASSWORD=\$DB_PASSWORD_TEMP
      fi

      FOLDER=\"\$(pwd)\"
      echo -n \"You are in folder \$FOLDER. Do you want to continue? [y/n]: \"
      read answer
      if [[ \$answer == \"y\" ]]; then
        break;
      elif [[ \$answer == \"n\" ]]; then
        exit;
      fi
    done

    git clone git@github.com:polyptychon/$DIR_NAME.git

    cd $DIR_NAME
    wp core config --dbname=\$DB_NAME --dbuser=\$DB_USER --dbpass=\$DB_PASSWORD --path=$PATH_TO_WORDPRESS

    if [ -f $PATH_TO_EXPORTS/remote.sql ]; then
      wp db import $PATH_TO_EXPORTS/remote.sql --path=$PATH_TO_WORDPRESS
    elif [ -f $PATH_TO_EXPORTS/local.sql ]; then
      sed \"s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g\" $PATH_TO_EXPORTS/local.sql > $PATH_TO_EXPORTS/remote.sql
      wp db import $PATH_TO_EXPORTS/remote.sql --path=$PATH_TO_WORDPRESS
      rm -rf $PATH_TO_EXPORTS/remote.sql
    fi
  else
    echo \" Only wordpress installations supported for now.\"
    exit;
  fi
fi

'"

}
