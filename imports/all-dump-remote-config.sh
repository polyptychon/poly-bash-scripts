#!/bin/bash

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
}

function all-dump-remote-config {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

LOCAL_PATHS=()

if [[ -z $REMOTE_PATH ]] && [[ ! -z REMOTE_SSH_ROOT_PATH ]]; then
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

echo -n "You are about to download ${bold}${red}ALL remote${reset}${reset_bold} config files from remote host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N: "
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
      if [[ -d $PATH_TO_WORDPRESS ]] && [[ -f $PATH_TO_WORDPRESS/wp-config.php ]]; then
        echo \$d
        cp $PATH_TO_WORDPRESS/wp-config.php ~/$PATH_TO_TEMP_EXPORTS/wp-config-\$d.php
      elif [[ -d $PATH_TO_DRUPAL ]] && [[ -f $PATH_TO_DRUPAL/sites/default/settings.php ]]; then
        echo \$d
        cp $PATH_TO_DRUPAL/sites/default/settings.php ~/$PATH_TO_TEMP_EXPORTS/settings-\$d.php
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
  if [[ -f $PATH_TO_TEMP_EXPORTS/wp-config-$d.php ]] || [[ -f $PATH_TO_TEMP_EXPORTS/settings-$d.php ]]; then
    if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
      cp $PATH_TO_TEMP_EXPORTS/wp-config-$d.php $d/$PATH_TO_WORDPRESS/wp-config.php
      echo "${bold}${green}Success${reset}${reset_bold}: Copy from ../$PATH_TO_TEMP_EXPORTS/wp-config-$d.php to $d/$PATH_TO_WORDPRESS/wp-config.php"
    elif [[ -d $d/$PATH_TO_DRUPAL ]]; then
      cp $PATH_TO_TEMP_EXPORTS/settings-$d.php $d/$PATH_TO_DRUPAL/sites/default/settings.php
      echo "${bold}${green}Success${reset}${reset_bold}: Copy from ../$PATH_TO_TEMP_EXPORTS/settings-$d.php to $d/$PATH_TO_DRUPAL/sites/default/settings.php"
    else
      echo "${bold}${red}Error${red}${reset_bold}: Copy ../$PATH_TO_TEMP_EXPORTS/wp-config-$d.php or ../$PATH_TO_TEMP_EXPORTS/settings-$d.php"
    fi
  else
    echo "${bold}${red}could not find $PATH_TO_TEMP_EXPORTS/wp-config-$d.php or $PATH_TO_TEMP_EXPORTS/settings-$d.php ${red}${reset_bold}"
  fi
done

rm -rf $PATH_TO_TEMP_EXPORTS
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
  rm -rf $PATH_TO_TEMP_EXPORTS
EOF

}
