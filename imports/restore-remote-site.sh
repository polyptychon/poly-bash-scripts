function restore-remote-site {
  set -e

  if [ -f .env ]; then
    source .env
  else
    echo ".env file does not exist"
    exit
  fi

  while (true); do
    FOLDER="$(pwd)"
    echo "You are in folder $FOLDER."
    echo -n "Do you want to restore remote site? [y/n]: "
    read answer
    if [[ $answer == "y" ]]; then
      break;
    elif [[ $answer == "n" ]]; then
      exit;
    else
      clear
    fi
  done

  restore-remote-repository quiet
  restore-remote-uploads quiet
  restore-remote-config quiet
  restore-remote-db quiet

}
