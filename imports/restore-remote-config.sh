function restore-remote-config {
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
      echo -n "Do you want to restore config to remote site? [y/n]: "
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
  if [ -d static ]; then
    echo "Warning. You should not copy local config"
  else
    if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
      if [ -f $PATH_TO_WORDPRESS/wp-config.php ]; then
        scp -rCP $SSH_PORT $PATH_TO_WORDPRESS/wp-config.php "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-config.php"
      fi
    elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
      if [ -f $PATH_TO_DRUPAL/sites/default/settings.php ]; then
        scp -rCP $SSH_PORT $PATH_TO_DRUPAL/sites/default/settings.php "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/settings.php"
      fi
    fi
  fi
}
