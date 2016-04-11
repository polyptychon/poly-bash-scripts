#Wordpress scripts

Install wp-cli: http://wp-cli.org/

Install github/hub: https://github.com/github/hub

Clone project in user root folder.
```
cd ~
git clone git@github.com:polyptychon/poly-bash-scripts.git
```
Give scripts permission to execute.

```
cd ~/poly-bash-scripts
sudo chmod 755 *.sh
```

###Update .bash_profile

```
#poly scripts
export POLY_SCRIPTS=~/poly-bash-scripts
export PATH="$POLY_SCRIPTS:$PATH"
alias poly="poly.sh"
source ~/poly-bash-scripts/.poly-completion.bash

#wp-cli
MAMP_PHP_LATEST=$(ls -t /Applications/MAMP/bin/php/ | head -1)
export MAMP_PHP=/Applications/MAMP/bin/php/$MAMP_PHP_LATEST/bin
export PATH="$MAMP_PHP:$PATH"

export MAMP_APACHE=/Applications/MAMP/bin/apache2/bin
export PATH="$MAMP_APACHE:$PATH"
```



###Create ".env" file in project root directory

```yaml
SSH_HOST=domain.com
SSH_PORT=22
SSH_USERNAME=user

REMOTE_DOMAIN=domain.com
LOCAL_DOMAIN=local:8888
REMOTE_PATH=./absolute/path/to/remote/folder

PATH_TO_WORDPRESS=./relative/path/to/wordpress
PATH_TO_EXPORTS=./relative/path/to/sql/exports

```

###Set ".global-env" inside ~/poly-bash-scripts directory

```
SSH_HOST=example.com
SSH_PORT=22
SSH_USERNAME=ssh_user
REMOTE_DB_NAME_PREFIX=ssh_user_
DEFAULT_DOMAIN=example.com
DEFAULT_WP_USER=example_admin
DEFAULT_DB_TABLE_PREFIX=example_
GITHUB_ACCOUNT=polyptychon
DB_USER=db-user
DB_PASSWORD=db-password
REMOTE_SSH_ROOT_PATH=./remote-path
PATH_TO_WORDPRESS=wordpress
PATH_TO_EXPORTS=exports
WP_USER_EMAIL=webadmin@example.com
```
