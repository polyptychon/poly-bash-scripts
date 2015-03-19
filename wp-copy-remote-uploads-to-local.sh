#!/bin/bash
set -e
source .env
scp -rCP $SSH_PORT "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/$PATH_TO_WORDPRESS/wp-content/uploads" $PATH_TO_WORDPRESS/wp-content/
