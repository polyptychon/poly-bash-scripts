#!/bin/bash
set -e
# load global variables
source ~/wp_scripts/.global-env

# load variables
source .env

# expect -c "
# spawn mysqldump -p -u $LOCAL_DATABASE_USERNAME $LOCAL_DATABASE
# expect -nocase \"password:\" {send \"$LOCAL_DATABASE_PASSWORD\r\"; interact}
# " > exports/temp.sql

# DIR_NAME=${PWD##*/}
# THEME_FILES=$PATH_TO_WORDPRESS/wp-content/themes/$DIR_NAME/*
# for f in $THEME_FILES
# do
#   if [[ ! "$f" =~ .png &&  ! "$f" =~ .tmp ]]; then
#     echo "Processing $f > $f.tmp theme_name=$DIR_NAME"
#     sed -e "s/theme_name/$DIR_NAME/g" $f > $f.tmp
#     mv -f $f.tmp $f
#   fi
# done
# ls -la $PATH_TO_WORDPRESS/wp-content/themes/$DIR_NAME/
