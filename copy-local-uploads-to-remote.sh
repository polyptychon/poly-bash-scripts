#!/bin/bash
set -e
source .env
read -p "You want replace remote uploads with local. Are you sure? Y/N " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
scp -rCP $SSH_PORT $PATH_TO_WORDPRESS/wp-content/uploads "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/"
fi

