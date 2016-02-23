#!/bin/bash

function get_env_value {
  if [[ -z $2 ]]; then
    ENV=.env
  else
    ENV=$2
  fi
  echo `sed -n "/$1/p" $ENV | sed -E "s/$1=//g"`
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

LOCAL_PATHS=()

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS="wordpress"
fi

echo -n "You are about to replace ${bold}${red}ALL local${reset}${reset_bold} databases with remote form host ${bold}${red}$SSH_HOST${reset}${reset_bold}. Are you sure? Y/N: "
read REPLY
if [[ $REPLY =~ ^[Nn]$ ]]; then
  echo "Exiting..."
  exit
fi

if [[ -z $PATH_TO_TEMP_EXPORTS ]]; then
  PATH_TO_TEMP_EXPORTS="temp_dump"
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
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
    LOCAL_DOMAIN=`get_env_value "LOCAL_DOMAIN"`
    REMOTE_DOMAIN=`get_env_value "REMOTE_DOMAIN"`
    sed -e "s/$REMOTE_DOMAIN/$LOCAL_DOMAIN/g;s/\<wordpress@$LOCAL_DOMAIN\>/\<wordpress@$REMOTE_DOMAIN\>/g;s/$d.$SSH_HOST/$LOCAL_DOMAIN/g" ../$PATH_TO_TEMP_EXPORTS/$d.sql > ../$PATH_TO_TEMP_EXPORTS/$d.temp.sql
    wp db import ../$PATH_TO_TEMP_EXPORTS/$d.temp.sql --path=$PATH_TO_WORDPRESS
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
