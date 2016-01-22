#!/bin/bash
set -e
function create_htaccess {
  if [ ! -f $PATH_TO_WORDPRESS/.htaccess ]; then
    echo "" >> $PATH_TO_WORDPRESS/.htaccess
    echo "# BEGIN WordPress" >> $PATH_TO_WORDPRESS/.htaccess
    echo "<IfModule mod_rewrite.c>" >> $PATH_TO_WORDPRESS/.htaccess
    echo "RewriteEngine On" >> $PATH_TO_WORDPRESS/.htaccess
    echo "RewriteBase /" >> $PATH_TO_WORDPRESS/.htaccess
    echo "RewriteRule ^index\.php$ - [L]" >> $PATH_TO_WORDPRESS/.htaccess
    echo "RewriteCond %{REQUEST_FILENAME} !-f" >> $PATH_TO_WORDPRESS/.htaccess
    echo "RewriteCond %{REQUEST_FILENAME} !-d" >> $PATH_TO_WORDPRESS/.htaccess
    echo "RewriteRule . /index.php [L]" >> $PATH_TO_WORDPRESS/.htaccess
    echo "</IfModule>" >> $PATH_TO_WORDPRESS/.htaccess
    echo "" >> $PATH_TO_WORDPRESS/.htaccess
    echo "# END WordPress" >> $PATH_TO_WORDPRESS/.htaccess
    echo "" >> $PATH_TO_WORDPRESS/.htaccess
    wp rewrite flush
  fi
}

function init-poly {

if [ -f .env ]; then
  source .env
fi
function get_db_prefix_from_sql_dump {
  echo `sed -n "/DROP TABLE IF EXISTS/p" $1 | sed -E "s/DROP TABLE IF EXISTS .//g" | sed -E "s/_.+//g" | head -n1`
}
DIR_NAME=${PWD##*/}
WP_SITE_TITLE=$DIR_NAME
WP_USER=poly_admin
WP_USER_PASSWORD="$(date | md5)"
DB_NAME="$(echo -e "${PWD##*/}" | sed -e 's/[[:space:]]/_/g;s/-/_/g')"
DB_PREFIX="poly_"

if [ ! -z ${DB_USER} ] && [ ! -z ${DB_PASSWORD} ] && [ ! -z ${DB_NAME} ]; then
  set +e
  RESULT=`mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW DATABASES" | grep -Fo $DB_NAME`
  set -e
  if [ ! -z ${RESULT} ]; then
    DATABASE_EXISTS=1
  else
    DATABASE_EXISTS=0
  fi
else
  DATABASE_EXISTS=0
fi

if [[ -f wp-cli.local.yml ]] && [[ -f .env ]] && [[ -f $PATH_TO_EXPORTS/local.sql ]] && [[ -f $PATH_TO_WORDPRESS/wp-config.php ]] && [[ $DATABASE_EXISTS == 1 ]]; then
  echo "Initialization is already done"
  exit
elif [[ -f wp-cli.local.yml ]] && [[ -f .env ]] && [[ -f $PATH_TO_EXPORTS/local.sql ]] && [[ ! -f $PATH_TO_WORDPRESS/wp-config.php ]]; then
  echo "Do special init"
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
  DB_PREFIX=`get_db_prefix_from_sql_dump $PATH_TO_EXPORTS/local.sql`
  if [ -z ${DB_PREFIX} ]; then
    DB_PREFIX="poly_"
  else
    DB_PREFIX=$DB_PREFIX"_"
  fi
  wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbprefix=$DB_PREFIX
  if [[ $DATABASE_EXISTS == 1 ]]; then
    echo -n "Database $DB_NAME already exists!. Do you want to drop database? Y/N: "
    read DROP_DATABASE
    if [[ $DROP_DATABASE =~ ^[Yy]$ ]]; then
      echo "Dropping Database"
      wp db drop --yes
      DATABASE_EXISTS=0
    fi
  fi
  if [[ $DATABASE_EXISTS == 0 ]]; then
    echo "create database"
    wp db create
    wp db import $PATH_TO_EXPORTS/local.sql --path=$PATH_TO_WORDPRESS
  fi
  create_htaccess

  exit
fi

if [[ $DATABASE_EXISTS == 1 ]]; then
  echo "Database $DB_NAME already exists!"
  exit
fi

if [[ -f $PATH_TO_WORDPRESS/wp-config.php ]]; then
  echo "$PATH_TO_WORDPRESS/wp-config.php already exists"
  exit
fi

if [[ -f .env ]]; then
  echo ".env file already exists"
  exit
fi

if [[ -f wp-cli.local.yml ]]; then
  echo "wp-cli.local.yml file already exists"
  exit
fi

if [[ -f $PATH_TO_EXPORTS/local.sql ]]; then
  echo "Database local sql dump already exists"
  exit
fi

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

  echo -n " # Wordpress admin email ($WP_USER_EMAIL):"
  read WP_USER_EMAIL_TEMP
  if [ ! -z ${WP_USER_EMAIL_TEMP} ]; then
    WP_USER_EMAIL=$WP_USER_EMAIL_TEMP
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


echo "SSH_HOST=$SSH_HOST" > $POLY_SCRIPTS_FOLDER/.global-env
echo "SSH_PORT=$SSH_PORT" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "SSH_USERNAME=$SSH_USERNAME" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "DB_USER=$DB_USER" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "DB_PASSWORD=$DB_PASSWORD" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "REMOTE_SSH_ROOT_PATH=$REMOTE_SSH_ROOT_PATH" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "PATH_TO_EXPORTS=$PATH_TO_EXPORTS" >> $POLY_SCRIPTS_FOLDER/.global-env
echo "WP_USER_EMAIL=$WP_USER_EMAIL" >> $POLY_SCRIPTS_FOLDER/.global-env


if [ ! -f wp-admin-password.txt ]; then
  echo "WP_USER_PASSWORD: $WP_USER_PASSWORD" > ./admin-password.txt
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
  echo "WP_USER_EMAIL=$WP_USER_EMAIL" >> .env
else
  echo "WARNING: .env file already exists"
  exit;
fi

git clone git@github.com:polyptychon/wp-init.git
cp wp-init/*.* ./
cp wp-init/.gitignore ./.gitignore
rm -rf wp-init

git clone git@github.com:polyptychon/static.git
rm -rf static/.git

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
cleanup_static "static/*"

sed -e "s/wordpress/$PATH_TO_WORDPRESS/g;s/exports/$PATH_TO_EXPORTS/g" ./.gitignore > ./.gitignore.tmp
mv -f ./.gitignore.tmp ./.gitignore

echo "#$WP_SITE_TITLE" > ./README.md
echo "http://polyptychon.github.io/$DIR_NAME/" >> ./README.md

wp core download
wp core config --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbprefix=$DB_PREFIX
wp db create
wp core install --title="$WP_SITE_TITLE" --admin_user="$WP_USER" --admin_password="$WP_USER_PASSWORD" --admin_email="$WP_USER_EMAIL"
wp user update $WP_USER --display_name=administrator --nickname=administrator
set +e
wp plugin install ewww-image-optimizer
set -e
# wp plugin install contact-form-7 --activate
# wp plugin install contact-form-7-success-page-redirects --activate
# wp plugin install regenerate-thumbnails
# wp plugin install wp-super-cache
# wp plugin install wp-super-cache-clear-cache-menu

git clone git@bitbucket.org:polyptychon/wp-paid-plugins.git
rm -rf wp-paid-plugins/.git
mv -f wp-paid-plugins/* $PATH_TO_WORDPRESS/wp-content/plugins
rm -rf wp-paid-plugins

set +e
  wp plugin activate advanced-custom-fields-pro
  wp plugin activate sitepress-multilingual-cms
  wp plugin activate wpml-string-translation
  wp plugin activate wpml-xliff
  wp plugin activate contact-form-7
  wp plugin activate contact-form-7-success-page-redirects
  wp plugin activate regenerate-thumbnails
  wp plugin activate ewww-image-optimizer
  wp plugin activate thumbnail-upscale
set -e

git clone git@github.com:polyptychon/wp-theme-template.git
rm -rf wp-theme-template/.git
mv -f wp-theme-template $PATH_TO_WORDPRESS/wp-content/themes/$DIR_NAME

function cleanup_theme {
  for f in $1;
  do
    if [[ -d $f ]]; then
      cleanup_theme "$f/*"
    fi
    echo $f
    if [[ "$f" =~ .json || "$f" =~ .php || "$f" =~ .css ]]; then
      sed -e "s/theme_name/$DIR_NAME/g" $f > $f.tmp
      mv -f $f.tmp $f
    fi
  done
}
cleanup_theme "$PATH_TO_WORDPRESS/wp-content/themes/$DIR_NAME/*"

wp theme activate $DIR_NAME

set +e
wp option update date_format "d\/m\/Y"
wp option update permalink_structure "\/%year%\/%monthnum%\/%day%\/%postname%\/"
wp option update category_base "\/posts"
wp option update gmt_offset "3"
wp option update rss_use_excerpt "1"
wp option update comment_registration "1"
wp option update default_comment_status "closed"
wp option update comment_moderation "1"
wp option update default_ping_status "closed"
wp option update gzipcompression "1"

wp option update thumbnail_size_w "263"
wp option update thumbnail_size_h "200"
wp option update thumbnail_crop "1"
wp option update medium_size_w "525"
wp option update medium_size_h "394"
wp option update large_size_w "1920"
wp option update large_size_h "1280"
wp option update image_default_size "medium"

wp post create --post_type=page --post_title='Homepage' --post_status=publish --page_template='page-templates/homepage.php'
wp post create --post_type=page --post_title='Νέα' --post_status=publish
wp post create --post_type=page --post_title='Σύνδεσμοι' --post_status=publish
wp post create --post_type=page --post_title='Επικοινωνία' --post_status=publish

wp option update show_on_front "page"
wp option update page_for_posts "5"
wp option update page_on_front "4"

wp menu create "Contact Menu"
wp menu create "Main Nav Menu"

# wp menu item add-post contact-menu 4 --title="Homepage"
wp menu item add-post main-nav-menu 5 --title="Νέα"

wp menu item add-post contact-menu 6 --title="Σύνδεσμοι"
wp menu item add-post contact-menu 7 --title="Επικοινωνία"

wp plugin update --all

create_htaccess

set -e


set +e
wp theme delete twentyfifteen
wp theme delete twentyfourteen
wp theme delete twentythirteen
set -e

set +e

git init
git add --all
git commit -m "initial commit"

mkdir ./exports
wp db optimize
source $POLY_SCRIPTS_FOLDER/imports/commit-local-db.sh
commit-local-db

set -e

if [[ $CREATE_REMOTE_GIT == "y" ]]; then
  set +e
  hub create -p polyptychon/$DIR_NAME
  if [ -f .env ]; then
    echo "GIT_REMOTE_ORIGIN_URL=git@github.com:polyptychon/$DIR_NAME.git" >> .env
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
