#!/bin/bash
set -e
source .env
scp -rCP 2222 wordpress/wp-content/uploads "$SSH_USERNAME@$SSH_HOST:$REMOTE_PATH/wordpress/wp-content/"
