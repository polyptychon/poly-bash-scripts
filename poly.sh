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
source $POLY_SCRIPTS_FOLDER/imports/all-import-remote-to-local-db.sh
source $POLY_SCRIPTS_FOLDER/imports/all-import-local-to-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/all-open-local-sites.sh
source $POLY_SCRIPTS_FOLDER/imports/all-update-sites.sh
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
source $POLY_SCRIPTS_FOLDER/imports/create-gh-pages-static.sh
source $POLY_SCRIPTS_FOLDER/imports/deploy-stage.sh
source $POLY_SCRIPTS_FOLDER/imports/deploy-static.sh
source $POLY_SCRIPTS_FOLDER/imports/import-local-to-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/import-remote-to-local-db.sh
source $POLY_SCRIPTS_FOLDER/imports/init-poly.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-site.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-repository.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-config.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-uploads.sh
source $POLY_SCRIPTS_FOLDER/imports/restore-remote-db.sh
source $POLY_SCRIPTS_FOLDER/imports/change-git-upstream.sh

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
    backup-remote-sites ${arguments[0]}
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
  function gh-pages-static {
    echo "gh-pages-static"
    create-gh-pages
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
  function remote-databases-to-local {
    echo "import all remote databases to local"
    all-import-remote-to-local-db
  }
  function local-databases-to-remote {
    echo "import all local databases to remote"
    all-import-local-to-remote-db
  }
  function copy-remote-uploads {
    echo "copy all remote uploads to local"
    all-copy-remote-uploads-to-local
  }
  function copy-local-uploads {
    echo "copy all local uploads to remote"
    all-copy-local-uploads-to-remote
  }
  function open-local-sites {
    echo "open all local sites"
    all-open-local-sites
  }
  function deploy {
    echo "deploy all sites to remote host"
    all-deploy-sites
  }
  function update {
    echo "update all sites"
    all-update-sites
  }
  options=("remote-databases-to-local" "local-databases-to-remote" "deploy" "update" "copy-remote-uploads" "copy-local-uploads" "open-local-sites")
  exec_arguments options[@]
}

#CHANGE
function change {
  options=("git-upstream")
  exec_arguments options[@]
}

function main {
  options=("init" "import" "backup" "restore" "commit" "copy" "create" "add" "deploy" "change" "all")
  exec_arguments options[@]
}

arguments=("$@")
main
