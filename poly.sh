#!/bin/bash
# set -e

POLY_SCRIPTS_FOLDER=~/poly-bash-scripts

if [[ -f $POLY_SCRIPTS_FOLDER/.global-env ]]; then
  source $POLY_SCRIPTS_FOLDER/.global-env
fi
source $POLY_SCRIPTS_FOLDER/imports/exec_arguments.sh
source $POLY_SCRIPTS_FOLDER/imports/add-custom-post-types.sh
source $POLY_SCRIPTS_FOLDER/imports/add-taxonomies.sh
source $POLY_SCRIPTS_FOLDER/imports/all-copy-local-uploads-to-remote.sh
source $POLY_SCRIPTS_FOLDER/imports/all-copy-remote-uploads-to-local.sh
source $POLY_SCRIPTS_FOLDER/imports/all-deploy-sites.sh
source $POLY_SCRIPTS_FOLDER/imports/all-dump-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/all-dump-remote-htaccess.sh
source $POLY_SCRIPTS_FOLDER/imports/all-dump-remote-env.sh
source $POLY_SCRIPTS_FOLDER/imports/all-dump-remote-config.sh
source $POLY_SCRIPTS_FOLDER/imports/all-exec-command.sh
source $POLY_SCRIPTS_FOLDER/imports/all-import-remote-to-local-db.sh
source $POLY_SCRIPTS_FOLDER/imports/all-import-local-to-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/all-npm-install.sh
source $POLY_SCRIPTS_FOLDER/imports/all-open-sites.sh
source $POLY_SCRIPTS_FOLDER/imports/all-open-pagespeed.sh
source $POLY_SCRIPTS_FOLDER/imports/all-open-validate-html.sh
source $POLY_SCRIPTS_FOLDER/imports/all-open-resizer.sh
source $POLY_SCRIPTS_FOLDER/imports/all-symlink-uploads.sh
source $POLY_SCRIPTS_FOLDER/imports/all-update-sites.sh
source $POLY_SCRIPTS_FOLDER/imports/backup-remote-sites.sh
source $POLY_SCRIPTS_FOLDER/imports/backup-remote-sites-light.sh
source $POLY_SCRIPTS_FOLDER/imports/bootstrap-wordpress.sh
source $POLY_SCRIPTS_FOLDER/imports/bootstrap-static.sh
source $POLY_SCRIPTS_FOLDER/imports/bootstrap-static-spa.sh
source $POLY_SCRIPTS_FOLDER/imports/change-git-upstream.sh
source $POLY_SCRIPTS_FOLDER/imports/check-uploads.sh
source $POLY_SCRIPTS_FOLDER/imports/clear-remote-cache.sh
source $POLY_SCRIPTS_FOLDER/imports/commit-local-db.sh
source $POLY_SCRIPTS_FOLDER/imports/commit-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-local-uploads-to-remote.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-remote-uploads-to-local.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-static-assets-to-wordpress.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-static-fonts-to-wordpress.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-static-images-to-wordpress.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-static-scripts-to-wordpress.sh
source $POLY_SCRIPTS_FOLDER/imports/copy-static-styles-to-wordpress.sh
source $POLY_SCRIPTS_FOLDER/imports/create-gh-pages.sh
source $POLY_SCRIPTS_FOLDER/imports/create-gh-pages-static.sh
source $POLY_SCRIPTS_FOLDER/imports/deploy-stage.sh
source $POLY_SCRIPTS_FOLDER/imports/deploy-static.sh
source $POLY_SCRIPTS_FOLDER/imports/import-local-to-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/import-remote-to-local-db.sh
source $POLY_SCRIPTS_FOLDER/imports/init-poly.sh
source $POLY_SCRIPTS_FOLDER/imports/init-static-poly.sh
source $POLY_SCRIPTS_FOLDER/imports/optimize-local-assets.sh
source $POLY_SCRIPTS_FOLDER/imports/optimize-local-uploads.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-site.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-repository.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-config.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-uploads.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-db.sh

#INIT
function init {
  echo "init"
  init-poly
}

#INIT
function init-static {
  echo "init static"
  init-static-poly
}

#IMPORT
function import {
  function local-database-to-remote {
    echo "local-database-to-remote"
    import-local-to-remote-db
  }
  function remote-database-to-local {
    echo "remote-database-to-local"
    import-remote-to-local-db
  }
  options=("local-database-to-remote" "remote-database-to-local")
  exec_arguments options[@]
}

#BACKUP
function backup {
  function remote-sites {
    echo "backup remote-sites"
    backup-remote-sites ${arguments[0]}
  }
  function remote-sites-light {
    echo "backup remote-sites-light"
    backup-remote-sites-light ${arguments[0]}
  }
  options=("remote-sites" "remote-sites-light")
  exec_arguments options[@]
}

#COPY
function copy {
  function local {
    function uploads-to-remote {
      echo "uploads-to-remote"
      copy-local-uploads-to-remote
    }
    options=("uploads-to-remote")
    exec_arguments options[@]
  }
  function remote {
    function uploads-to-local {
      echo "uploads-to-local"
      copy-remote-uploads-to-local
    }
    options=("uploads-to-local")
    exec_arguments options[@]
  }
  function static {
    function assets {
      echo "assets"
      copy-static-assets-to-wordpress
    }
    function styles {
      echo "styles"
      copy-static-styles-to-wordpress
    }
    function scripts {
      echo "scripts"
      copy-static-scripts-to-wordpress
    }
    function fonts {
      echo "fonts"
      copy-static-fonts-to-wordpress
    }
    function images {
      echo "images"
      copy-static-images-to-wordpress
    }
    options=("assets" "styles" "scripts" "fonts" "images")
    exec_arguments options[@]
  }
  options=("local" "remote" "static")
  exec_arguments options[@]
}

#CREATE
function create {
  function gh-pages {
    echo "gh-pages"
    create-gh-pages
  }
  function gh-pages-static {
    echo "gh-pages-static"
    create-gh-pages-static
  }
  options=("gh-pages" "gh-pages-static")
  exec_arguments options[@]
}

#COMMIT
function commit {
  function local-database {
    echo "commit local-database"
    commit-local-db
  }
  function remote-database {
    echo "commit remote-database"
    commit-remote-db
  }
  options=("local-database" "remote-database")
  exec_arguments options[@]
}

#ADD
function add {
  function custom-post-types {
    echo "custom-post-types"
    add-custom-post-types
  }
  function taxonomies {
    echo "taxonomies"
    add-taxonomies
  }
  options=("custom-post-types" "taxonomies")
  exec_arguments options[@]
}

#DEPLOY
function deploy {
  function stage {
    echo "deploy stage"
    deploy-stage
  }
  function static {
    echo "deploy static"
    deploy-static
  }
  function production {
    echo "not yet implemented production deploy"
  }
  options=("stage" "static" "production")
  exec_arguments options[@]
}

#CLEAR
function clear {
  function remote-cache {
    echo "clear remote-cache"
    clear-remote-cache
  }
  options=("remote-cache")
  exec_arguments options[@]
}

#CHECK
function check {
  function uploads {
    echo "check uploads"
    check-uploads
  }
  options=("uploads")
  exec_arguments options[@]
}

#BOOTSTRAP
function bootstrap {
  function wordpress {
    echo "wordpress"
    bootstrap-wordpress
  }
  function static {
    echo "static"
    bootstrap-static
  }
  function static-spa {
    echo "static spa"
    bootstrap-static-spa
  }
  options=("wordpress" "static" "static-spa")
  exec_arguments options[@]
}

#DEPLOY
function restore {
  function remote {
    function site {
      echo "restore remote site"
      restore-remote-site
    }
    function repository {
      echo "restore repository"
      restore-remote-repository
    }
    function config {
      echo "restore config"
      restore-remote-config
    }
    function uploads {
      echo "restore uploads"
      restore-remote-uploads
    }
    function database {
      echo "restore database"
      restore-remote-db
    }
    options=("site" "repository" "config" "uploads" "database")
    exec_arguments options[@]
  }
  options=("remote")
  exec_arguments options[@]
}

#ALL
function all {
  function import-remote-databases-to-local {
    echo "import all remote databases to local"
    all-import-remote-to-local-db
  }
  function import-local-databases-to-remote {
    echo "import all local databases to remote"
    all-import-local-to-remote-db
  }
  function copy-remote-uploads {
    echo "copy all remote uploads to local"
    all-copy-remote-uploads-to-local ${arguments[0]}
  }
  function copy-local-uploads {
    echo "copy all local uploads to remote"
    all-copy-local-uploads-to-remote
  }
  function npm-install {
    echo "run npm install to all folders"
    all-npm-install
  }
  function open-sites {
    echo "open all local sites"
    all-open-sites
  }
  function open-pagespeed {
    echo "open all local sites for pagespeed"
    all-open-pagespeed
  }
  function open-validate-html {
    echo "open all local sites for validation"
    all-open-validate-html
  }
  function open-resizer {
    echo "open all local sites to Google resizer"
    all-open-resizer
  }
  function symlink-uploads {
    echo "Symlink uploads"
    all-symlink-uploads
  }
  function deploy {
    echo "deploy all sites to remote host"
    all-deploy-sites
  }
  function dump-remote-db {
    echo "dump all remote databases"
    all-dump-remote-db
  }
  function dump-remote-htaccess {
    echo "dump all remote .htaccess files"
    all-dump-remote-htaccess
  }
  function dump-remote-env {
    echo "dump all remote .env files"
    all-dump-remote-env
  }
  function dump-remote-config {
    echo "dump all remote config files"
    all-dump-remote-config
  }
  function exec-command {
    echo "deploy all sites to remote host"
    all-exec-command
  }
  function update {
    echo "update all sites"
    all-update-sites
  }
  options=("dump-remote-db" "dump-remote-htaccess" "dump-remote-env" "dump-remote-config" "import-remote-databases-to-local" "import-local-databases-to-remote" "deploy" "update" "copy-remote-uploads" "copy-local-uploads" "open-sites" "open-pagespeed" "open-validate-html" "open-resizer" "symlink-uploads" "exec-command" "npm-install")
  exec_arguments options[@]
}

#CHANGE
function change {
  options=("git-upstream")
  exec_arguments options[@]
}

#OPTIMIZE
function optimize {
  function local-assets {
    echo "optimize local assets"
    optimize-local-assets
  }
  function local-uploads {
    echo "optimize local uploads"
    optimize-local-uploads
  }
  options=("local-assets" "local-uploads")
  exec_arguments options[@]
}

function main {
  options=("optimize" "init" "init-static" "import" "backup" "bootstrap" "restore" "clear" "commit" "check" "copy" "create" "add" "deploy" "change" "all")
  exec_arguments options[@]
}

arguments=("$@")
main
