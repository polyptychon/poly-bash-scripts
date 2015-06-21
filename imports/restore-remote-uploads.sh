function restore-remote-uploads {
  set -e

  if [ -f .env ]; then
    source .env
  else
    echo ".env file does not exist"
    exit
  fi

  if [ -z $1 ] && [ $1=="quiet" ]; then
    while (true); do
      FOLDER="$(pwd)"
      echo "You are in folder $FOLDER."
      echo -n "Do you want to restore uploads to remote site? [y/n]: "
      read answer
      if [[ $answer == "y" ]]; then
        break;
      elif [[ $answer == "n" ]]; then
        exit;
      else
        clear
      fi
    done
  fi

  rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
  if [[ $rsync_version != '3.1.0' ]]; then
    echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
  fi

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    if [ -d $PATH_TO_WORDPRESS/wp-content/uploads/ ]; then
      rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_WORDPRESS/wp-content/uploads/ $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/
      # scp -rCP $SSH_PORT $PATH_TO_WORDPRESS/wp-content/uploads/ "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/"
    else
      echo "Folder uploads does not exist"
      exit
    fi
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    if [ -d $PATH_TO_DRUPAL/sites/default/files ]; then
      rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_DRUPAL/sites/default/files $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/
      # scp -rCP $SSH_PORT $PATH_TO_DRUPAL/sites/default/files "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/"
    else
      echo "Folder files does not exist"
      exit
    fi
  fi

}
