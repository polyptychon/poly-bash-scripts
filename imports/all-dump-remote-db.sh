#!/bin/bash

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
}

function all-dump-remote-db {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

UP=$(pgrep mysql | wc -l);
if [[ "$UP" -ne 1 ]]; then
  echo "Could not connect to local mysql. Exiting..."
  exit
fi

LOCAL_PATHS=()

if [[ -z $REMOTE_PATH ]] && [[ !-z REMOTE_SSH_ROOT_PATH ]]; then
  REMOTE_PATH=$REMOTE_SSH_ROOT_PATH
else
  echo "REMOTE_PATH variable is not set!"
  exit
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi

if [[ -z $PATH_TO_DRUPAL ]]; then
  PATH_TO_DRUPAL="drupal_site"
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

echo -n "You are about to download ${bold}${red}ALL remote${reset}${reset_bold} databases from remote host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N: "
read REPLY
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "Exiting..."
  exit
fi

if [[ -z $PATH_TO_TEMP_EXPORTS ]]; then
  PATH_TO_TEMP_EXPORTS="temp_dump"
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]] || [[ -d $d/$PATH_TO_DRUPAL ]]; then
    PATH_NAME=$(echo $d | sed -E "s/\///g")
    LOCAL_PATHS+=($PATH_NAME)
  fi
done

ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
  if [[ ! -d $PATH_TO_TEMP_EXPORTS ]]; then
    mkdir $PATH_TO_TEMP_EXPORTS
  fi
  cd $REMOTE_PATH
  for d in ${LOCAL_PATHS[@]}; do
    dl=\$(echo \$d | tr '[:upper:]' '[:lower:]')
    if [[ -d \$d ]] || [[ -d \$dl ]]; then
      if [[ -d \$d ]]; then
        cd \$d
      elif [[ -d \$dl ]]; then
        cd \$dl
      fi
      if [[ -d $PATH_TO_WORDPRESS ]]; then
        echo \$d
        export DB_NAME=\$(sed -n "/DB_NAME/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_NAME'.?.?'//g" | sed -r "s/'.+//g")
        export DB_USER=\$(sed -n "/DB_USER/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_USER'.?.?'//g" | sed -r "s/'.+//g")
        export DB_PASSWORD=\$(sed -n "/DB_PASSWORD/p" $PATH_TO_WORDPRESS/wp-config.php | sed -r "s/.+DB_PASSWORD'.?.?'//g" | sed -r "s/'.+//g")
        mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > ~/$PATH_TO_TEMP_EXPORTS/\$d.sql
      elif [[ -d $PATH_TO_DRUPAL ]]; then
        echo \$d
        export DB_NAME=\$(sed -n "/'database' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -r "s/^.+'database' => '//g" | sed -r "s/',$//g")
        export DB_USER=\$(sed -n "/'username' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -r "s/^.+'username' => '//g" | sed -r "s/',$//g")
        export DB_PASSWORD=\$(sed -n "/'password' => /p" $PATH_TO_DRUPAL/sites/default/settings.php | sed '/^\s\*/d' | sed -r "s/^.+'password' => '//g" | sed -r "s/',$//g")
        mysqldump -u\$DB_USER -p\$DB_PASSWORD \$DB_NAME > ~/$PATH_TO_TEMP_EXPORTS/\$d.sql
      fi
      cd ..
    fi
  done
  exit
EOF

if [[ ! -d $PATH_TO_TEMP_EXPORTS ]]; then
  mkdir $PATH_TO_TEMP_EXPORTS
fi
rsync -avz -e "ssh -p $SSH_PORT" --progress $SSH_USERNAME@$SSH_HOST:~/$PATH_TO_TEMP_EXPORTS ./

for d in ${LOCAL_PATHS[@]}; do
  if [[ -f $PATH_TO_TEMP_EXPORTS/$d.sql ]]; then
    if [[ -d $d/exports ]]; then
      cp ../$PATH_TO_TEMP_EXPORTS/$d.sql $d/exports/remote.sql
    else
      echo "could not find path $d/exports"
    fi
  else
    echo "could not find $d.sql"
  fi
done

rm -rf $PATH_TO_TEMP_EXPORTS
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
  rm -rf $PATH_TO_TEMP_EXPORTS
EOF

}
