
#!/usr/bin/env bash

# curl -sS https://getcomposer.org/installer | php
# mv composer.phar /usr/local/bin/composer

mkdir -p ~/.wp-cli/commands
git clone https://github.com/wp-cli/server-command.git ~/.wp-cli/commands/server
git clone git@github.com:wp-cli/wp-super-cache-cli.git ~/.wp-cli/commands/super-cache

if [ ! -f config.yml ]; then
  echo "Creating config.yml file"
  echo "require:" > ~/.wp-cli/config.yml
  echo "  - commands/server/command.php" >> ~/.wp-cli/config.yml
  echo "  - commands/super-cache/cli.php" >> ~/.wp-cli/config.yml
else
  echo "WARNING: Make sure you have vendor/autoload.php inside config.yml"
fi

echo "Setup completed."
