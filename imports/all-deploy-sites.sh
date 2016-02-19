#!/bin/bash
if [[ -f .env ]]; then
  source .env
else
  echo "Could not find .env. Exiting..."
  exit
fi

function get_env_value {
  echo `sed -n "/$1/p" .env | sed -E "s/$1=//g"`
}
function clean_up() {
  if [[ -d .git ]]; then
    set +e
    git stash pop --quiet
    cd ..
    set -e
  fi
}

function all-deploy-sites() {

if [[ -z $PATH_TO_WORDPRESS ]]; then
  PATH_TO_WORDPRESS=wordpress
fi

for d in */ ; do
  if [[ -d $d/$PATH_TO_WORDPRESS ]]; then
    cd "$d"
    set -e
    trap 'echo "could not read .env"; clean_up' INT TERM EXIT
    # REMOTE_DOMAIN=`get_env_value "REMOTE_DOMAIN"`
    # SSH_PORT=`get_env_value "SSH_PORT"`
    # SSH_USERNAME=`get_env_value "SSH_USERNAME"`
    # SSH_HOST=`get_env_value "SSH_HOST"`
    REMOTE_PATH=`get_env_value "REMOTE_PATH"`
    REMOTE_PATH_LOWER=$(echo $REMOTE_PATH | tr '[:upper:]' '[:lower:]')
    echo $REMOTE_PATH

    set +e
    git stash --quiet
    git pull --quiet
    set -e

    set -e
    trap 'echo "could not push"; clean_up' INT TERM EXIT
    git push

    set +e
    LOCAL_COMMIT_HASH=$(git rev-parse HEAD)
    ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'
      if [[ -d $REMOTE_PATH ]] || [[ -d $REMOTE_PATH_LOWER ]]; then
        if [[ -d $REMOTE_PATH ]]; then
          cd $REMOTE_PATH
        elif [[ -d $REMOTE_PATH_LOWER ]]; then
          cd $REMOTE_PATH_LOWER
        fi

        REMOTE_COMMIT_HASH=\$(git rev-parse HEAD)
        if [ $LOCAL_COMMIT_HASH == \$REMOTE_COMMIT_HASH ]; then
          echo \"Everything is up to date. No action is required\"
          exit
        else
          git stash --quiet
          git status
          git pull
          git stash pop --quiet
          exit
        fi
      else
        echo \"Could not find path $REMOTE_PATH in remote server\"
      fi
    '"
    set -e

    trap 'echo "could not open chrome"; clean_up' INT TERM EXIT
    # open "http://"$REMOTE_DOMAIN/wp-admin/
    set +e

    git stash pop --quiet

    echo
    trap 'echo "OK"; clean_up' INT TERM EXIT
    cd ..
  fi
done

}