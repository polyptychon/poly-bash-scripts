#!/bin/bash

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
}
function get_drupal_config_value {
  echo `sed -n "/\'$1\'.\=\>/p" $PATH_TO_DRUPAL/sites/default/settings.php | sed -E "s/.+\'$1\'.\=\>//g" | sed -E "s/\'\,$//g" | sed -E "s/\'//g" | sed -E "s/$1|password|username|databasename|(\/path\/to\/databasefilename)//g"`
}

function all-import-remote-to-local-db {

if [[ -f .env ]]; then
  source .env
  if [[ -f .env_override ]]; then
    source .env_override
  fi
else
  echo "Could not find .env. Exiting..."
  exit
fi

if [[ ! -z $1 ]]; then
  ASK_FOR_CONFIRMATION=$1
else
  ASK_FOR_CONFIRMATION="y"
fi

UP=$(pgrep mysql | wc -l);
if [[ "$UP" -ne 1 ]]; then
  echo "Could not connect to local mysql. Exiting..."
  exit
fi

LOCAL_PATHS=()

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

if [[ -z $PATH_TO_TEMP_EXPORTS ]]; then
  PATH_TO_TEMP_EXPORTS="temp_dump"
fi

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi

if [[ -z $PATH_TO_DRUPAL ]]; then
  PATH_TO_DRUPAL="drupal_site"
fi

if [[ -z $REMOTE_PATH ]]; then
  echo "REMOTE_PATH variable is not set!"
  exit
fi

if [[ $ASK_FOR_CONFIRMATION =~ ^[Yy]$  ]]; then
  echo -n "You are about to replace ${bold}${red}ALL local${reset}${reset_bold} databases with remote form host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N: "
  read REPLY
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Exiting..."
    exit
  fi
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
    cd $d
    if [[ -d $PATH_TO_WORDPRESS ]]; then
      LOCAL_DOMAIN=`get_env_value "LOCAL_DOMAIN"`
      REMOTE_DOMAIN=`get_env_value "REMOTE_DOMAIN"`
      DB_NAME=`get_wp_config_value 'DB_NAME'`
      DB_USER=`get_wp_config_value 'DB_USER'`
      DB_PASSWORD=`get_wp_config_value 'DB_PASSWORD'`
      DB_TABLE_PREFIX=`sed -n '/table_prefix/p' $PATH_TO_WORDPRESS/wp-config.php | sed -E 's/.table_prefix ? ?= ? ?.//g' | sed -E 's/.;$//g'`

      DOMAIN_NAME_FROM_MYSQL=`mysql -u$DB_USER -p$DB_PASSWORD -s -N -e "SELECT option_value FROM \\\`$DB_NAME\\\`."$DB_TABLE_PREFIX"options WHERE option_name='siteurl'" | sed -E 's/^http(s)?:\/\///g'`
      STATUS_COLOR=`tput setaf 1`
      if [[ $DOMAIN_NAME_FROM_MYSQL == $LOCAL_DOMAIN ]]; then
        STATUS_COLOR=`tput setaf 2`
      fi
      echo
      echo "LOCAL DOMAIN IN DATABASE: ${bold}${STATUS_COLOR}$DOMAIN_NAME_FROM_MYSQL${reset}${reset_bold}"
      echo "LOCAL DOMAIN IN ENV     : ${bold}${STATUS_COLOR}$LOCAL_DOMAIN${reset}${reset_bold}"
      echo
      sed -e "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g;s/\<wordpress@$LOCAL_DOMAIN\>/\<wordpress@$REMOTE_DOMAIN\>/g;s/$d.$SSH_HOST/$LOCAL_DOMAIN/g" ../$PATH_TO_TEMP_EXPORTS/$d.sql > ../$PATH_TO_TEMP_EXPORTS/$d.temp.sql
      wp db import ../$PATH_TO_TEMP_EXPORTS/$d.temp.sql --path=$PATH_TO_WORDPRESS
    elif [ ! -z $PATH_TO_DRUPAL ] && [ -d $PATH_TO_DRUPAL ]; then
      DB_NAME=`get_drupal_config_value 'database'`
      DB_USER=`get_drupal_config_value 'username'`
      DB_PASSWORD=`get_drupal_config_value 'password'`
      mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME < ../$PATH_TO_TEMP_EXPORTS/$d.sql
      echo
      echo "${bold}${green}Success${reset}${reset_bold}: Imported from ../$PATH_TO_TEMP_EXPORTS/$d.sql"
    fi
    cd ..
  else
    echo "could not find $d.sql"
  fi
done

rm -rf $PATH_TO_TEMP_EXPORTS
ssh -T -p $SSH_PORT $SSH_USERNAME@$SSH_HOST <<EOF
  rm -rf $PATH_TO_TEMP_EXPORTS
EOF

}
