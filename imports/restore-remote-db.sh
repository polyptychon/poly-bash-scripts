function restore-remote-db {
  set -e

  if [ -f .env ]; then
    source .env
  fi

  while (true); do
    FOLDER="$(pwd)"
    echo "You are in folder $FOLDER."
    echo -n "Do you want to restore database to remote site? [y/n]: "
    read answer
    if [[ $answer == "y" ]]; then
      break;
    elif [[ $answer == "n" ]]; then
      exit;
    else
      clear
    fi
  done

  echo "restore database"
  scp -rCP $SSH_PORT $PATH_TO_EXPORTS/remote.sql "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql"

  if [ ! -z $PATH_TO_WORDPRESS ] && [ -d $PATH_TO_WORDPRESS ]; then
    #import local converted sql dump file to remote db
    ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
    cd $REMOTE_PATH
    wp db import $PATH_TO_EXPORTS/temp.sql --path=$PATH_TO_WORDPRESS
    exit
    '"
  elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
    #import local converted sql dump file to remote db
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'database' => '//g" | sed -E "s/',$//g")
export DB_USER=\$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'username' => '//g" | sed -E "s/',$//g")
export DB_PASSWORD=\$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'password' => '//g" | sed -E "s/',$//g")
mysql -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME < $PATH_TO_EXPORTS/temp.sql
exit
EOF
  fi

}
