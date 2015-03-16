#!/bin/bash
set -e

DIR_NAME=${PWD##*/}
WP_SITE_TITLE=$DIR_NAME

if [ -f wp-cli.local.yml ]; then
  echo "ERROR: wp-cli.local.yml file already exists"
  exit;
fi

#Getting the app key and secret from the user
while (true); do

  echo -n " # Local Database name: "
  read DB_NAME

  echo -n " # Local Database user: "
  read DB_USER

  echo -n " # Local Database password: "
  read DB_PASSWORD

  echo -n " # Wordpress admin user: "
  read WP_USER

  echo -n " # Wordpress admin password: "
  read WP_USER_PASSWORD

  echo "Continue? [y/n]: "
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

if [ ! -f wp-cli.local.yml ]; then
  echo "path: wordpress" > ./wp-cli.local.yml
  echo "url: http://$DIR_NAME.local:8888" >> ./wp-cli.local.yml
  echo "user: $WP_USER" >> ./wp-cli.local.yml
else
  echo "WARNING: wp-cli.local.yml file already exists"
  exit;
fi

git clone git@github.com:HarrisSidiropoulos/wp-init.git
cp wp-init/*.* ./
cp wp-init/.gitignore ./.gitignore
rm -rf wp-init
wp core download
wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD
wp db create
wp core install --title=$WP_SITE_TITLE --admin_user=$WP_USER --admin_password=$WP_USER_PASSWORD --admin_email=webadmin@polyptychon.gr
wp plugin update --all

backup-local-db.sh