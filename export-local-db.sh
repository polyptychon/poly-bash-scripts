#!/bin/bash
source .env
expect -c "
spawn mysqldump -p -u $LOCAL_DATABASE_USERNAME $LOCAL_DATABASE
expect -nocase \"password:\" {send \"$LOCAL_DATABASE_PASSWORD\r\"; interact}
" > exports/temp.sql
sed 's/-- Dump completed on....................//g' exports/temp.sql > exports/local.sql
sed "s/$LOCAL_DOMAIN/$REMOTE_DOMAIN/g" exports/local.sql > exports/remote.sql
