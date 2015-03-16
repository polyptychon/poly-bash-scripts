#!/bin/bash
set -e
if [ -f ~/wp_scripts/.global-env ]; then
  source ~/wp_scripts/.global-env
fi

DIR_NAME=${PWD##*/}
WP_SITE_TITLE=$DIR_NAME
WP_USER_PASSWORD="$(openssl rand -base64 16)"

if [ -f wp-cli.local.yml ]; then
  echo "ERROR: wp-cli.local.yml file already exists"
  exit;
fi

#Prompt user for settings
while (true); do

  echo -n " # Local Database name: "
  read DB_NAME

  if [ -z ${DB_USER+x} ]; then
    echo -n " # Local Database user: "
    read DB_USER
  fi

  if [ -z ${DB_PASSWORD+x} ]; then
    echo -n " # Local Database password: "
    read DB_PASSWORD
  fi

  echo -n " # Wordpress admin user: "
  read WP_USER

  echo " # Wordpress admin password: $WP_USER_PASSWORD"
  FOLDER="$(pwd)"
  echo -n "You are in folder $FOLDER.Do you want to continue? [y/n]: "
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

if [ ! -f ~/wp_scripts/.global-env ]; then
  echo "DB_USER=$DB_USER" > ~/wp_scripts/.global-env
  echo "DB_PASSWORD=$DB_PASSWORD" >> ~/wp_scripts/.global-env
fi

if [ ! -f wp-admin-password.txt ]; then
  echo "WP_USER_PASSWORD: $WP_USER_PASSWORD" > ./wp-admin-password.txt
else
  echo "WARNING: wp-admin-password.txt file already exists"
  exit;
fi

if [ ! -f wp-cli.local.yml ]; then
  echo "path: wordpress" > ./wp-cli.local.yml
  echo "url: http://$DIR_NAME.local:8888" >> ./wp-cli.local.yml
  echo "user: $WP_USER" >> ./wp-cli.local.yml
else
  echo "WARNING: wp-cli.local.yml file already exists"
  exit;
fi

if [ ! -f .env ]; then
  echo "SSH_HOST=polyptychon.gr" > .env
  echo "SSH_PORT=2222" >> .env
  echo "SSH_USERNAME=xarisd" >> .env
  echo "REMOTE_DOMAIN=$DIR_NAME.polyptychon.gr" >> .env
  echo "REMOTE_DOMAIN=$DIR_NAME.local:8888" >> .env
  echo "REMOTE_PATH=./domains/$DIR_NAME" >> .env
  echo "PATH_TO_WORDPRESS=./wordpress" >> .env
  echo "PATH_TO_EXPORTS=./exports" >> .env
else
  echo "WARNING: .env file already exists"
  exit;
fi

git clone git@github.com:HarrisSidiropoulos/wp-init.git
cp wp-init/*.* ./
cp wp-init/.gitignore ./.gitignore
rm -rf wp-init

echo "#$WP_SITE_TITLE" > ./README.md
echo "http://polyptychon.github.io/$DIR_NAME/" >> ./README.md

wp core download
wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD
wp db create
wp core install --title=$WP_SITE_TITLE --admin_user=$WP_USER --admin_password=$WP_USER_PASSWORD --admin_email=webadmin@polyptychon.gr
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
