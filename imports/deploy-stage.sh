#!/bin/bash

function deploy-stage {
set -e

# load variables
if [ -f .env ]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo ".env file does not exist. Exiting..."
  exit
fi

DIR_NAME=${PWD##*/}
DIR_NAME_LOWER=$(echo $DIR_NAME | tr '[:upper:]' '[:lower:]')

if [[ -z $REMOTE_DB_NAME_PREFIX ]]; then
  REMOTE_DB_NAME_PREFIX="polyptyc_"
fi

if [ -f .env ]; then
  GIT_REMOTE_ORIGIN_URL_TEMP=$(git config --get remote.origin.url)
  if [ -z $GIT_REMOTE_ORIGIN_URL ]; then
    echo "GIT_REMOTE_ORIGIN_URL=$GIT_REMOTE_ORIGIN_URL_TEMP" >> .env
    GIT_REMOTE_ORIGIN_URL=$GIT_REMOTE_ORIGIN_URL_TEMP
    git add .env
    git commit -m "add GIT_REMOTE_ORIGIN_URL variable"
  fi
fi
if [ -z $GIT_REMOTE_ORIGIN_URL ]; then
  echo "Git remote origin url is not defined! $GIT_REMOTE_ORIGIN_URL"
  exit
fi
LOCAL_COMMIT_HASH=$(git rev-parse HEAD)
if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
  IS_WORDPRESS=1
else
  IS_WORDPRESS=0
fi
if [ -f $PATH_TO_WORDPRESS/wp-config.php ]; then
  DB_PREFIX=`sed -n "/table_prefix/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.table_prefix {0,2}= {0,2}'//g" | sed -E "s/'.+//g"`
else
  echo "$PATH_TO_WORDPRESS/wp-config.php does not exists! Exiting"
  exit
fi

ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
if [[ -d $REMOTE_PATH ]]; then

  cd $REMOTE_PATH
  REMOTE_COMMIT_HASH=\$(git rev-parse HEAD)

  if [ $LOCAL_COMMIT_HASH -eq \$REMOTE_COMMIT_HASH ]; then
    echo \"Everything is up to date. No action is required\"
    exit
  else
    echo \"Remember to git push your local changes first!\"
    git stash clear
    git stash --quiet
    git status
    git pull
    git stash pop --quiet
    exit
  fi
else
  if [ $IS_WORDPRESS -eq 1 ]; then
    cd $REMOTE_SSH_ROOT_PATH

    while (true); do
      echo -n \" Remote Database name ($REMOTE_DB_NAME_PREFIX$DIR_NAME_LOWER): \"
      read DB_NAME_TEMP
      if [ ! -z \${DB_NAME_TEMP} ]; then
        DB_NAME=\$DB_NAME_TEMP
      else
        DB_NAME=$REMOTE_DB_NAME_PREFIX$DIR_NAME_LOWER
      fi

      echo -n \" Remote Database user ($REMOTE_DB_NAME_PREFIX$DIR_NAME_LOWER): \"
      read DB_USER_TEMP
      if [ ! -z \${DB_USER_TEMP} ]; then
        DB_USER=\$DB_USER_TEMP
      else
        DB_USER=$REMOTE_DB_NAME_PREFIX$DIR_NAME_LOWER
      fi

      echo -n \" Remote Database password: \"
      read DB_PASSWORD_TEMP
      if [ ! -z \${DB_PASSWORD_TEMP} ]; then
        DB_PASSWORD=\$DB_PASSWORD_TEMP
      fi

      echo -n \"Do you want to create a symlink? [y/n]: \"
      read answer
      if [[ \$answer -eq \"y\" ]]; then
        echo -n \" Symlink path (~/public_html/$REMOTE_DOMAIN): \"
        read SYMLINK_PATH_TEMP
        if [ ! -z \${SYMLINK_PATH_TEMP} ]; then
          SYMLINK_PATH=\$SYMLINK_PATH_TEMP
        else
          SYMLINK_PATH="~/public_html/$REMOTE_DOMAIN"
        fi
      fi

      FOLDER=\"\$(pwd)\"
      echo -n \"You are in folder \$FOLDER. Do you want to continue? [y/n]: \"
      read answer
      if [[ \$answer -eq \"y\" ]]; then
        break;
      elif [[ \$answer -eq \"n\" ]]; then
        exit;
      fi
    done

    git clone $GIT_REMOTE_ORIGIN_URL
    if [[ -d $DIR_NAME ]]; then
      cd $DIR_NAME
    elif [[ -d $DIR_NAME_LOWER ]]; then
      cd $DIR_NAME_LOWER
    else
      echo "$DIR_NAME does not exists! Exiting"
      exit
    fi
    wp core config --dbname=\$DB_NAME --dbuser=\$DB_USER --dbpass=\$DB_PASSWORD --path=$PATH_TO_WORDPRESS  --dbprefix=$DB_PREFIX

    if [ ! -z \${SYMLINK_PATH} ]; then
      FOLDER=\"\$(pwd)\"
      ln -s "\$FOLDER/$PATH_TO_WORDPRESS" \$SYMLINK_PATH
    fi

    if [ -f $PATH_TO_EXPORTS/local.sql ]; then
      sed \"s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g\" $PATH_TO_EXPORTS/local.sql > $PATH_TO_EXPORTS/temp.sql
      wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
      rm -rf $PATH_TO_EXPORTS/temp.sql
    fi

    if [ ! -f $PATH_TO_WORDPRESS/.htaccess ]; then
      echo \"\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"# BEGIN WordPress\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"<IfModule mod_rewrite.c>\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"RewriteEngine On\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"RewriteBase /\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"RewriteRule ^index\.php$ - [L]\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"RewriteCond %{REQUEST_FILENAME} !-f\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"RewriteCond %{REQUEST_FILENAME} !-d\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"RewriteRule . /index.php [L]\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"</IfModule>\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"# END WordPress\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"\" >> $PATH_TO_WORDPRESS/.htaccess

      echo \"# BEGIN Optimization\" >> $PATH_TO_WORDPRESS/.htaccess

      echo \"<IfModule mod_deflate.c>\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"<FilesMatch \\\"\\\\\.(js|css|html|htm|php|xml|svg)$\\\">\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"SetOutputFilter DEFLATE\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"</FilesMatch>\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"</IfModule>\" >> $PATH_TO_WORDPRESS/.htaccess

      echo \"# 480 weeks\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"<FilesMatch \\\"\\\.(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf|woff|svg)\$\\\">\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"Header set Cache-Control \\\"max-age=290304000, public\\\"\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"</FilesMatch>\" >> $PATH_TO_WORDPRESS/.htaccess

      echo \"# 2 DAYS\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"<FilesMatch \\\"\\\.(xml|txt)$\\\">\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"Header set Cache-Control \\\"max-age=172800, public, must-revalidate\\\"\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"</FilesMatch>\" >> $PATH_TO_WORDPRESS/.htaccess

      echo \"# 2 HOURS\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"<FilesMatch \\\"\\\.(html|htm)$\\\">\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"Header set Cache-Control \\\"max-age=7200, must-revalidate\\\"\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"</FilesMatch>\" >> $PATH_TO_WORDPRESS/.htaccess

      echo \"# END Optimization\" >> $PATH_TO_WORDPRESS/.htaccess
      echo \"\" >> $PATH_TO_WORDPRESS/.htaccess
      wp rewrite flush
    fi
  else
    echo \" Only wordpress installations supported for now.\"
    exit;
  fi
fi

'"

}
