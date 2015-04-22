function restore-repository {
  set -e

  if [ -f .env ]; then
    source .env
  fi

  while (true); do
    FOLDER="$(pwd)"
    echo -n "You are in folder $FOLDER. Do you want to restore repository to remote site? [y/n]: "
    read answer
    if [[ $answer == "y" ]]; then
      break;
    elif [[ $answer == "n" ]]; then
      exit;
    else
      clear
    fi
  done

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
    if [ -z ${GIT_SSH_CLONE_URL} ]; then
      echo -n \"git SSH clone URL: \"
      read GIT_SSH_CLONE_URL
    fi
    if [ ! -z \${GIT_SSH_CLONE_URL} ]; then
      git clone \$GIT_SSH_CLONE_URL
    fi

  fi

  '"

}
