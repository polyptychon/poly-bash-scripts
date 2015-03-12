#!/bin/bash
set -e
source .env
scp -rCP 2222 "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/wordpress/wp-content/uploads" wordpress/wp-content/
