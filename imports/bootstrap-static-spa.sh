#!/bin/bash
set -e

function bootstrap-static-spa {

if [ -f .env ]; then
  source .env
fi

DIR_NAME=${PWD##*/}

if [[ -f .env ]]; then
  echo "Initialization is already done"
  exit
fi
if [[ -z $GITHUB_ACCOUNT ]]; then
  echo "You must define a GITHUB_ACCOUNT variable in .global-env. example: GITHUB_ACCOUNT=polyptychon"
  echo "Exiting..."
  exit
fi
if [[ -z $DEFAULT_DOMAIN ]]; then
  echo "You must define a DEFAULT_DOMAIN variable in .global-env. example: DEFAULT_DOMAIN=polyptychon.gr"
  echo "Exiting..."
  exit
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

#Prompt user for settings
while (true); do

  echo -n "Do you want to create private github repository? [y/n]: "
  read CREATE_REMOTE_GIT

  echo -n " # SSH HOST ($SSH_HOST): "
  read SSH_HOST_TEMP
  if [ ! -z ${SSH_HOST_TEMP} ]; then
    SSH_HOST=$SSH_HOST_TEMP
  fi

  echo -n " # SSH PORT ($SSH_PORT): "
  read SSH_PORT_TEMP
  if [ ! -z ${SSH_PORT_TEMP} ]; then
    SSH_PORT=$SSH_PORT_TEMP
  fi

  echo -n " # SSH USERNAME ($SSH_USERNAME): "
  read SSH_USERNAME_TEMP
  if [ ! -z ${SSH_USERNAME_TEMP} ]; then
    SSH_USERNAME=$SSH_USERNAME_TEMP
  fi

  echo -n " # Remote SSH domains root path ($REMOTE_SSH_ROOT_PATH): "
  read REMOTE_SSH_ROOT_PATH_TEMP
  if [ ! -z ${REMOTE_SSH_ROOT_PATH_TEMP} ]; then
    REMOTE_SSH_ROOT_PATH=$REMOTE_SSH_ROOT_PATH_TEMP
  fi

  FOLDER="$(pwd)"
  echo -n "You are in folder ${bold}${red}$FOLDER${reset}${reset_bold}. Do you want to continue? [y/n]: "
  read answer
  if [[ $answer == "y" ]]; then
    break;
  elif [[ $answer == "n" ]]; then
    exit;
  fi

done

git clone git@github.com:polyptychon/static-spa.git ./
rm -rf .git

if [ ! -f .env ]; then
  echo "SSH_HOST=$SSH_HOST" > .env
  echo "SSH_PORT=$SSH_PORT" >> .env
  echo "SSH_USERNAME=$SSH_USERNAME" >> .env
  echo "REMOTE_DOMAIN=$DIR_NAME.$DEFAULT_DOMAIN" >> .env
  echo "LOCAL_DOMAIN=$DIR_NAME.local:8888" >> .env
  echo "REMOTE_PATH=$REMOTE_SSH_ROOT_PATH/$DIR_NAME" >> .env
else
  echo "WARNING: .env file already exists"
  exit;
fi

function cleanup_static {
  for f in $1;
  do
    if [[ -d $f ]]; then
      cleanup_static "$f/*"
    elif [[ "$f" =~ .json || "$f" =~ .js || "$f" =~ .css || "$f" =~ .scss || "$f" =~ .less || "$f" =~ .html || "$f" =~ .jade || "$f" =~ .coffee || "$f" =~ .yml ]]; then
      sed -e "s/site_name/$DIR_NAME/g" $f > $f.tmp
      mv -f $f.tmp $f
    fi
  done
}
cleanup_static "./*"

echo "#$DIR_NAME" > ./README.md
echo "http://$GITHUB_ACCOUNT.github.io/$DIR_NAME/" >> ./README.md

set +e

git init
git add --all
git commit -m "initial commit"

set -e

if [[ $CREATE_REMOTE_GIT == "y" ]]; then
  set +e
  hub create -p $GITHUB_ACCOUNT/$DIR_NAME
  if [ -f .env ]; then
    echo "GIT_REMOTE_ORIGIN_URL=git@github.com:$GITHUB_ACCOUNT/$DIR_NAME.git" >> .env
    git add .env
    git commit -m "add GIT_REMOTE_ORIGIN_URL variable to .env"
  fi
  git push -u origin master
  set -e
elif [[ $CREATE_REMOTE_GIT == "n" ]]; then
  echo "exiting"
  exit;
fi
}
