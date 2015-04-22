#!/bin/bash
# set -e

POLY_SCRIPTS_FOLDER=~/poly-bash-scripts

if [[ -f $POLY_SCRIPTS_FOLDER/.global-env ]]; then
  source $POLY_SCRIPTS_FOLDER/.global-env
fi
source $POLY_SCRIPTS_FOLDER/imports/exec_arguments.sh
source $POLY_SCRIPTS_FOLDER/imports/add-custom-post-types.sh
source $POLY_SCRIPTS_FOLDER/imports/add-taxonomies.sh
source $POLY_SCRIPTS_FOLDER/imports/backup-remote-sites.sh
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
source $POLY_SCRIPTS_FOLDER/imports/deploy-stage.sh
source $POLY_SCRIPTS_FOLDER/imports/import-local-to-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/import-remote-to-local-db.sh
source $POLY_SCRIPTS_FOLDER/imports/init-poly.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-site.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-repository.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-config.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-uploads.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-db.sh

#INIT
function init {
  echo "init"
  init-poly
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
    backup-remote-sites
  }
  options=("remote-sites")
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
  options=("gh-pages")
  exec_arguments options[@]
}

#Commit
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
  function production {
    echo "not yet implemented production deploy"
  }
  options=("stage" "production")
  exec_arguments options[@]
}

#DEPLOY
function restore {
  function site {
    echo "restore remote site"
    restore-remote-site
  }
  function repository {
    echo "restore repository"
    restore-repository
  }
  function config {
    echo "restore config"
    restore-config
  }
  function uploads {
    echo "restore uploads"
    restore-uploads
  }
  function database {
    echo "restore database"
    restore-db
  }
  options=("site" "repository" "config" "uploads" "database")
  exec_arguments options[@]
}

function main {
  options=("init" "import" "backup" "restore" "commit" "copy" "create" "add" "deploy")
  exec_arguments options[@]
}

arguments=("$@")
main
