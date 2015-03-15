README.md


# expect -c "
# spawn mysqldump -p -u $LOCAL_DATABASE_USERNAME $LOCAL_DATABASE
# expect -nocase \"password:\" {send \"$LOCAL_DATABASE_PASSWORD\r\"; interact}
# " > exports/temp.sql
