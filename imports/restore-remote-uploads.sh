function restore-remote-uploads {
  set -e

  if [ -f .env ]; then
    source .env
  fi

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

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    scp -rCP $SSH_PORT $PATH_TO_WORDPRESS/wp-content/uploads/ "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/"
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    scp -rCP $SSH_PORT $PATH_TO_DRUPAL/sites/default/files "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default/"
  fi

}
