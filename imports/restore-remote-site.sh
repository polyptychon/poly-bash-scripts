function restore-remote-site {
  set -e

  if [ -f .env ]; then
    source .env
  else
    echo ".env file does not exist"
    exit
  fi

  restore-remote-repository
  restore-remote-uploads
  restore-remote-config
  restore-remote-db

}
