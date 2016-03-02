#!/bin/bash

function get_wp_config_value {
  echo `sed -n "/$1/p" $PATH_TO_WORDPRESS/wp-config.php | sed -E "s/.+$1'.?.?'//g" | sed -E "s/');$//g"`
}

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
}

function all-import-local-to-remote-db {

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

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi

if [[ -z $PATH_TO_TEMP_EXPORTS ]]; then
  PATH_TO_TEMP_EXPORTS="temp_dump"
fi

if [[ ! -d $PATH_TO_TEMP_EXPORTS ]]; then
  mkdir $PATH_TO_TEMP_EXPORTS
fi

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
reset_bold=`tput rmso`

if [[ ! -z $SSH_HOST ]] && [[ ! -z $SSH_PORT ]] && [[ ! -z $SSH_USERNAME ]] && [[ ! -z $REMOTE_PATH ]]; then
  echo "import all local databases to remote host: ${bold}${red}$SSH_HOST${reset}${reset_bold}"
else
  echo "You must add a SSH_HOST, SSH_PORT, SSH_USERNAME and REMOTE_PATH variable to .env file. Exiting..."
  exit
fi

echo -n "You are about to replace ${bold}${red}ALL${reset}${reset_bold} remote databases to host ${bold}${red}$SSH_HOST${reset}${reset_bold} with local. Are you sure? Y/N: "
read REPLY
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "Exiting..."
  exit
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    PATH_NAME=$(echo $d | sed -E "s/\///g")
    LOCAL_PATHS+=($PATH_NAME)
    cd $d

    DB_NAME=`get_wp_config_value 'DB_NAME'`
    DB_USER=`get_wp_config_value 'DB_USER'`
    DB_PASSWORD=`get_wp_config_value 'DB_PASSWORD'`

    # export local db to sql dump file
    mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > ../$PATH_TO_TEMP_EXPORTS/$PATH_NAME.sql
    echo "${bold}${green}Success${reset}${reset_bold}: File $PATH_NAME.sql"
    cd ..
  fi
done

rsync_version=`rsync --version | sed -n "/version/p" | sed -E "s/rsync.{1,3}.version //g" | sed -E "s/  protocol version.{1,5}//g"`
if [[ $rsync_version != '3.1.0' ]]; then
  echo "Warning! You must upgrade rsync. Your rsync version is : $rsync_version"
fi
rsync --iconv=UTF-8-MAC,UTF-8 --delete -avz -e "ssh -p $SSH_PORT" --progress $PATH_TO_TEMP_EXPORTS $SSH_USERNAME@$SSH_HOST:$REMOTE_PATH

ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
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
        if [[ true ]] || [[ -f $REMOTE_PATH/$PATH_TO_TEMP_EXPORTS/\$d.sql ]]; then
          if [[ -f .env ]]; then
            export LOCAL_DOMAIN=\$(sed -n "/LOCAL_DOMAIN/p" .env | sed -r "s/LOCAL_DOMAIN=//g")
            export REMOTE_DOMAIN=\$(sed -n "/REMOTE_DOMAIN/p" .env | sed -r "s/REMOTE_DOMAIN=//g")
          fi
          if [[ -f .env_override ]]; then
            export REMOTE_DOMAIN=\$(sed -n "/REMOTE_SERVER/p" .env_override | sed -r "s/REMOTE_SERVER=//g")
          fi
          export DB_NAME=\$(sed -n \"/DB_NAME/p\" $PATH_TO_WORDPRESS/wp-config.php | sed -r \"s/.+DB_NAME.,\s?.//g\" | sed -r \"s/.\);$//g\")
          export DB_USER=\$(sed -n \"/DB_USER/p\" $PATH_TO_WORDPRESS/wp-config.php | sed -r \"s/.+DB_USER.,\s?.//g\" | sed -r \"s/.\);$//g\")
          export DB_PASSWORD=\$(sed -n \"/DB_PASSWORD/p\" $PATH_TO_WORDPRESS/wp-config.php | sed -r \"s/.+DB_PASSWORD.,\s?.//g\" | sed -r \"s/.\);$//g\")
          export DB_TABLE_PREFIX=\$(sed -n \"/table_prefix/p\" $PATH_TO_WORDPRESS/wp-config.php | sed -r \"s/^\s?\s?.table_prefix\s?\s?=\s?\s?.//g\" | sed -r \"s/.;$//g\")
          export SQL_STRING=\"SELECT option_value FROM \\\`\$DB_NAME\\\`.\"\$DB_TABLE_PREFIX\"options WHERE option_name=\\\"siteurl\\\"\"
          export DOMAIN_NAME_FROM_MYSQL=\$(mysql -u\$DB_USER -p\$DB_PASSWORD -s -N -e \"\$SQL_STRING\" | sed -r \"s/^http(s)?:\/\///g\")

          if [[ \$DOMAIN_NAME_FROM_MYSQL == \$LOCAL_DOMAIN ]]; then
            echo \"REMOTE DOMAIN IN DATABASE: ${bold}${green}\$DOMAIN_NAME_FROM_MYSQL${reset}${reset_bold}\"
            echo \"REMOTE DOMAIN IN ENV     : ${bold}${green}\$REMOTE_DOMAIN${reset}${reset_bold}\"
          else
            echo \"REMOTE DOMAIN IN DATABASE: ${bold}${red}\$DOMAIN_NAME_FROM_MYSQL${reset}${reset_bold}\"
            echo \"REMOTE DOMAIN IN ENV     : ${bold}${red}\$REMOTE_DOMAIN${reset}${reset_bold}\"
          fi

          echo -n \" Remote Domain (\$REMOTE_DOMAIN): \"
          read REMOTE_DOMAIN_TEMP
          if [ ! -z \${REMOTE_DOMAIN_TEMP} ]; then
            REMOTE_DOMAIN=\$REMOTE_DOMAIN_TEMP
          fi
          sed -r \"s/\$LOCAL_DOMAIN/\$REMOTE_DOMAIN/g\" $REMOTE_PATH/$PATH_TO_TEMP_EXPORTS/\$d.sql > $REMOTE_PATH/$PATH_TO_TEMP_EXPORTS/\$d.temp.sql
          wp db import $REMOTE_PATH/$PATH_TO_TEMP_EXPORTS/\$d.temp.sql --path=$PATH_TO_WORDPRESS
          echo
        else
          echo \"Could not find sqldump: $REMOTE_PATH/$PATH_TO_TEMP_EXPORTS/\$d.sql\"
        fi
      fi
      cd ..
    fi
  done
  rm -rf $REMOTE_PATH/$PATH_TO_TEMP_EXPORTS

'"
rm -rf $PATH_TO_TEMP_EXPORTS

}
