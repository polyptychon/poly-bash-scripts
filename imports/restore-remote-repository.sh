function restore-remote-repository {
  set -e

  if [ -f .env ]; then
    source .env
    if [[ -f .env_override ]]; then
      source .env_override
    fi
  else
    echo ".env file does not exist"
    exit
  fi

  if [ -z $1 ] && [ $1 == "quiet" ]; then
    while (true); do
      FOLDER="$(pwd)"
      echo "You are in folder $FOLDER."
      echo -n "Do you want to restore repository to remote site? [y/n]: "
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

  if [ -z $REMOTE_PATH ]; then
    echo "Variable REMOTE_PATH is not set"
    exit
  fi
  if [[ -z $GITHUB_ACCOUNT ]]; then
    echo "You must define a GITHUB_ACCOUNT variable in .global-env. example: GITHUB_ACCOUNT=polyptychon"
    echo "Exiting..."
    exit
  fi
  set +e
  DIR_NAME=${PWD##*/}
  ssh -t -p $SSH_PORT $SSH_USERNAME@$SSH_HOST bash -c "'

  if [[ -d $REMOTE_PATH ]]; then

    cd $REMOTE_PATH
    REMOTE_COMMIT_HASH=\$(git rev-parse HEAD)

    echo \"Remember to git push your local changes first!\"
    git stash --quiet
    git status
    git pull
    git stash pop --quiet
    exit

  else

    cd $REMOTE_SSH_ROOT_PATH
    echo ${GIT_REMOTE_ORIGIN_URL}
    if [ -z ${GIT_REMOTE_ORIGIN_URL} ]; then
      echo -n \"git SSH clone URL (git@github.com:$GITHUB_ACCOUNT/$DIR_NAME.git): \"
      read GIT_REMOTE_ORIGIN_URL
      if [ ! -z \${GIT_REMOTE_ORIGIN_URL} ]; then
        git clone \$GIT_REMOTE_ORIGIN_URL
      else
        git clone git@github.com:$GITHUB_ACCOUNT/$DIR_NAME.git
      fi
    else
      git clone $GIT_REMOTE_ORIGIN_URL
    fi


  fi

  '"
  set -e
}
