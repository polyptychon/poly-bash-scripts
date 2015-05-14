#!/bin/bash

function backup-remote-sites {
  set -e
  if [ ! -z $2 ] && [ -d "$1 $2" ]; then
    echo $1 $2
    cd "$1 $2"
  elif [ ! -z $1 ] && [ -d $1 ]; then
    echo $1
    cd $1
  fi

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
    echo "REMOTE_SSH_ROOT_PATH=$REMOTE_SSH_ROOT_PATH" >> .env
    echo "PATH_TO_WORDPRESS=$PATH_TO_WORDPRESS" >> .env
    echo "PATH_TO_EXPORTS=$PATH_TO_EXPORTS" >> .env
    echo "PATH_TO_DRUPAL=$PATH_TO_DRUPAL" >> .env
  fi

  if [ ! -f sites.txt ]; then
    while (true); do

      echo -n " # Add remote site folder for backup: "
      read backup_site
      echo "$backup_site" >> sites.txt

      echo -n "Do you want to add another remote site for backup? [y/n]: "
      read answer
      if [[ $answer == "n" ]]; then
        break;
      fi

    done
  fi
  now="$(date +'%d/%m/%Y')"

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
      set +e
      rsync --delete -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads $e/$PATH_TO_WORDPRESS/wp-content/
      rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-config.php $e/$PATH_TO_WORDPRESS/wp-config.php
      # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $e/$PATH_TO_WORDPRESS/wp-content/
      # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-config.php" $e/$PATH_TO_WORDPRESS/wp-config.php
      set -e
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/DB_NAME/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_NAME'.?.?'//g" | sed -E "s/'.+//g")
export DB_USER=\$(sed -n "/DB_USER/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_USER'.?.?'//g" | sed -E "s/'.+//g")
export DB_PASSWORD=\$(sed -n "/DB_PASSWORD/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+DB_PASSWORD'.?.?'//g" | sed -E "s/'.+//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF
      if [ ! -d $e/$PATH_TO_EXPORTS ]; then
        mkdir $e/$PATH_TO_EXPORTS
      fi
      set +e
      rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $e/$PATH_TO_EXPORTS/remote.sql
      # scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $e/$PATH_TO_EXPORTS/remote.sql
      set -e
    elif ssh -p $SSH_PORT $SSH_USERNAME@$SSH_HOST [ -d $REMOTE_PATH/$PATH_TO_DRUPAL ]; then # if is a drupal site
      if [ ! -d $e/$PATH_TO_DRUPAL ]; then
        mkdir $e/$PATH_TO_DRUPAL
        mkdir $e/$PATH_TO_DRUPAL/sites
      fi
      set +e
      rsync --delete -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default $e/$PATH_TO_DRUPAL/sites/
      rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/.htaccess $e/$PATH_TO_DRUPAL/.htaccess
      # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_DRUPAL/sites/default" $e/$PATH_TO_DRUPAL/sites/
      set -e
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
cd $REMOTE_PATH

export DB_NAME=\$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'database' => '//g" | sed -E "s/',$//g")
export DB_USER=\$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'username' => '//g" | sed -E "s/',$//g")
export DB_PASSWORD=\$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -E "s/^.+'password' => '//g" | sed -E "s/',$//g")
mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > $PATH_TO_EXPORTS/temp.sql
exit
EOF
      if [ ! -d $e/$PATH_TO_EXPORTS ]; then
        mkdir $e/$PATH_TO_EXPORTS
      fi
      set +e
      rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $e/$PATH_TO_EXPORTS/remote.sql
      # scp -CP $SSH_PORT $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_EXPORTS/temp.sql $e/$PATH_TO_EXPORTS/remote.sql
      set -e
    fi

    set +e
    rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/.env $e/.env 2> /dev/null
    # scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/.env" $e/.env 2> /dev/null
    set -e
  done

  set +e
  if [ ! -d .git ]; then
    git init
  fi
  git add --all
  now="$(date +'%d/%m/%Y')"
  git commit -m "backup at $now"
  set -e
}
