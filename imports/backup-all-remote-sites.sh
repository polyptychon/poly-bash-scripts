#!/bin/bash

function backup-all-remote-sites {
  set -e

  if [ -f .env ]; then
    source .env
  else
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

      echo -n " # Relative path to drupal ($PATH_TO_DRUPAL): "
      read PATH_TO_DRUPAL_TEMP
      if [ ! -z ${PATH_TO_DRUPAL_TEMP} ]; then
        if [ -z ${PATH_TO_DRUPAL} ] && [ -f $POLY_SCRIPTS_FOLDER/.global-env ]; then
          echo "PATH_TO_DRUPAL=$PATH_TO_DRUPAL_TEMP" >> $POLY_SCRIPTS_FOLDER/.global-env
        fi
        PATH_TO_DRUPAL=$PATH_TO_DRUPAL_TEMP
      fi

      echo -n " # Relative path to exports ($PATH_TO_EXPORTS): "
      read PATH_TO_EXPORTS_TEMP
      if [ ! -z ${PATH_TO_EXPORTS_TEMP} ]; then
        PATH_TO_EXPORTS=$PATH_TO_EXPORTS_TEMP
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

    echo "SSH_HOST=$SSH_HOST" > .env
    echo "SSH_PORT=$SSH_PORT" >> .env
    echo "SSH_USERNAME=$SSH_USERNAME" >> .env
    echo "REMOTE_DOMAIN=$DIR_NAME.$SSH_HOST" >> .env
    echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> .env
    echo "PATH_TO_EXPORTS=$PATH_TO_EXPORTS" >> .env
    echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> .env
    echo "PATH_TO_DRUPAL=$PATH_TO_DRUPAL" >> .env
  fi

  if [ ! -f sites.txt ]; then
    while (true); do

      echo -n " # Add site for backup: "
      read backup_site
      echo "$backup_site" >> sites.txt

      echo -n "Do you want to add another site for backup? [y/n]: "
      read answer
      if [[ $answer == "n" ]]; then
        break;
      fi

    done
  fi

  sites=()

  # Read the file in parameter and fill the array named "array"
  getArray() {
      i=0
      while read line # Read a line
      do
          sites[i]=$line # Put it into the array
          i=$(($i + 1))
      done < $1
  }

  getArray "sites.txt"

  for e in "${sites[@]}"
  do
    if [ ! -d $e ]; then
      mkdir $e
    fi
    REMOTE_PATH=$REMOTE_SSH_ROOT_PATH/$e

    if ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/$PATH_TO_WORDPRESS ]; then # if is a wordpress site
      if [ ! -d $e/$PATH_TO_WORDPRESS ]; then
        mkdir $e/$PATH_TO_WORDPRESS
        mkdir $e/$PATH_TO_WORDPRESS/wp-content/
      fi
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $e/$PATH_TO_WORDPRESS/wp-content/uploads
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-config.php" $e/$PATH_TO_WORDPRESS/wp-config.php
    elif ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/$PATH_TO_DRUPAL ]; then # if is a drupal site
      if [ ! -d $e/$PATH_TO_DRUPAL ]; then
        mkdir $e/$PATH_TO_DRUPAL
        mkdir $e/$PATH_TO_DRUPAL/sites
      fi
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default" $e/$PATH_TO_DRUPAL/sites/default
    fi
    if ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/.env ]; then
      scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/.env" $e/.env
    fi

  done
}
