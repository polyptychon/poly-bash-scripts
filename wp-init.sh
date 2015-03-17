#!/bin/bash
set -e
if [ -f ~/wp_scripts/.global-env ]; then
  source ~/wp_scripts/.global-env
fi

if [ -f wp-cli.local.yml ]; then
  echo "ERROR: wp-cli.local.yml file already exists"
  exit;
fi

DIR_NAME=${PWD##*/}
WP_SITE_TITLE=$DIR_NAME
WP_USER_PASSWORD="$(date | md5)"
DB_NAME="$(echo -e "${PWD##*/}" | sed -e 's/[[:space:]]/_/g;s/-/_/g')"
WP_USER=admin

#Prompt user for settings
while (true); do

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

  echo -n " # Relative path to wordpress ($PATH_TO_WORDPRESS): "
  read PATH_TO_WORDPRESS_TEMP
  if [ ! -z ${PATH_TO_WORDPRESS_TEMP} ]; then
    PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS_TEMP
  fi

  echo -n " # Relative path to exports ($PATH_TO_EXPORTS): "
  read PATH_TO_EXPORTS_TEMP
  if [ ! -z ${PATH_TO_EXPORTS_TEMP} ]; then
    PATH_TO_EXPORTS=$PATH_TO_EXPORTS_TEMP
  fi

  echo -n " # Local Database name ($DB_NAME): "
  read DB_NAME_TEMP
  if [ ! -z ${DB_NAME_TEMP} ]; then
    DB_NAME=$DB_NAME_TEMP
  fi

  echo -n " # Local Database user ($DB_USER): "
  read DB_USER_TEMP
  if [ ! -z ${DB_USER_TEMP} ]; then
    DB_USER=$DB_USER_TEMP
  fi

  echo -n " # Local Database password ($DB_PASSWORD): "
  read DB_PASSWORD_TEMP
  if [ ! -z ${DB_PASSWORD_TEMP} ]; then
    DB_PASSWORD=$DB_PASSWORD_TEMP
  fi

  echo -n " # Wordpress admin user ($WP_USER): "
  read WP_USER_TEMP
  if [ ! -z ${WP_USER_TEMP} ]; then
    WP_USER=$WP_USER_TEMP
  fi

  echo -n " # Wordpress admin password ($WP_USER_PASSWORD):"
  read WP_USER_PASSWORD_TEMP
  if [ ! -z ${WP_USER_PASSWORD_TEMP} ]; then
    WP_USER_PASSWORD=$WP_USER_PASSWORD_TEMP
  fi

  FOLDER="$(pwd)"
  echo -n "You are in folder $FOLDER. Do you want to continue? [y/n]: "
  read answer
  if [[ $answer == "y" ]]; then
    break;
  elif [[ $answer == "n" ]]; then
    exit;
  fi

done

PASSWORD_IS_OK=`mysqladmin --user=$DB_USER --password=$DB_PASSWORD ping | grep -c "mysqld is alive"`

if [ $PASSWORD_IS_OK == 0 ]; then
  exit;
fi


echo "SSH_HOST=$SSH_HOST" > ~/wp_scripts/.global-env
echo "SSH_PORT=$SSH_PORT" >> ~/wp_scripts/.global-env
echo "SSH_USERNAME=$SSH_USERNAME" >> ~/wp_scripts/.global-env
echo "DB_USER=$DB_USER" >> ~/wp_scripts/.global-env
echo "DB_PASSWORD=$DB_PASSWORD" >> ~/wp_scripts/.global-env
echo "REMOTE_SSH_ROOT_PATH=$REMOTE_SSH_ROOT_PATH" >> ~/wp_scripts/.global-env
echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> ~/wp_scripts/.global-env
echo "PATH_TO_EXPORTS=$PATH_TO_EXPORTS" >> ~/wp_scripts/.global-env


if [ ! -f wp-admin-password.txt ]; then
  echo "WP_USER_PASSWORD: $WP_USER_PASSWORD" > ./wp-admin-password.txt
else
  echo "WARNING: wp-admin-password.txt file already exists"
  exit;
fi

if [ ! -f wp-cli.local.yml ]; then
  echo "path: $PATH_TO_WORDPRESS" > ./wp-cli.local.yml
  echo "url: http://$DIR_NAME.local:8888" >> ./wp-cli.local.yml
  echo "user: $WP_USER" >> ./wp-cli.local.yml
else
  echo "WARNING: wp-cli.local.yml file already exists"
  exit;
fi

if [ ! -f .env ]; then
  echo "SSH_HOST=$SSH_HOST" > .env
  echo "SSH_PORT=$SSH_PORT" >> .env
  echo "SSH_USERNAME=$SSH_USERNAME" >> .env
  echo "REMOTE_DOMAIN=$DIR_NAME.$SSH_HOST" >> .env
  echo "LOCAL_DOMAIN=$DIR_NAME.local:8888" >> .env
  echo "REMOTE_PATH=$REMOTE_SSH_ROOT_PATH/$DIR_NAME" >> .env
  echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> .env
  echo "PATH_TO_EXPORTS=$PATH_TO_EXPORTS" >> .env
else
  echo "WARNING: .env file already exists"
  exit;
fi

git clone git@github.com:HarrisSidiropoulos/wp-init.git
cp wp-init/*.* ./
cp wp-init/.gitignore ./.gitignore
rm -rf wp-init

sed -e "s/wordpress/$PATH_TO_WORDPRESS/g;s/exports/$PATH_TO_EXPORTS/g" ./.gitignore > ./.gitignore.tmp
mv -f ./.gitignore.tmp ./.gitignore

echo "#$WP_SITE_TITLE" > ./README.md
echo "http://polyptychon.github.io/$DIR_NAME/" >> ./README.md

wp core download
wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD
wp db create
wp core install --title="$WP_SITE_TITLE" --admin_user="$WP_USER" --admin_password="$WP_USER_PASSWORD" --admin_email="webadmin@polyptychon.gr"
wp plugin update --all

git init
git add --all
git commit -m "initial commit"

set +e
hub create -p polyptychon/$DIR_NAME
git push -u origin master
set -e

set +e
mkdir ./exports
backup-local-db.sh
set -e
git push
