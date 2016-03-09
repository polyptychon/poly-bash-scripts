#!/usr/bin/env bash
# bash completion for the `poly` command

_poly_complete() {
  local cur
  # Pointer to current completion word.
  # By convention, it's named "cur" but this isn't strictly necessary.
  cur=${COMP_WORDS[COMP_CWORD]}
  if [[ ${COMP_WORDS[1]} == "import" ]]; then
    COMPREPLY=( $( compgen -W 'local-database-to-remote remote-database-to-local' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "check" ]]; then
    COMPREPLY=( $( compgen -W 'uploads' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "bootstrap" ]]; then
    COMPREPLY=( $( compgen -W 'wordpress static' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "clear" ]]; then
    COMPREPLY=( $( compgen -W 'remote-cache' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "backup" ]]; then
    COMPREPLY=( $( compgen -W 'remote-sites' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "all" ]]; then
    COMPREPLY=( $( compgen -W 'import-remote-databases-to-local import-local-databases-to-remote deploy update copy-remote-uploads copy-local-uploads npm-install open-sites symlink-uploads exec-command' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "commit" ]]; then
    COMPREPLY=( $( compgen -W 'local-database remote-database' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "copy" ]]; then
    if [[ ${COMP_WORDS[2]} == "local" ]]; then
      COMPREPLY=( $( compgen -W 'uploads-to-remote' -- $cur ) );
    elif [[ ${COMP_WORDS[2]} == "remote" ]]; then
      COMPREPLY=( $( compgen -W 'uploads-to-local' -- $cur ) );
    elif [[ ${COMP_WORDS[2]} == "static" ]]; then
      COMPREPLY=( $( compgen -W 'assets styles scripts fonts images' -- $cur ) );
    else
      COMPREPLY=( $( compgen -W 'local remote static' -- $cur ) );
    fi
  elif [[ ${COMP_WORDS[1]} == "change" ]]; then
    COMPREPLY=( $( compgen -W 'git-upstream' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "create" ]]; then
    COMPREPLY=( $( compgen -W 'gh-pages gh-pages-static' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "add" ]]; then
    COMPREPLY=( $( compgen -W 'custom-post-types taxonomies' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "deploy" ]]; then
    COMPREPLY=( $( compgen -W 'stage static production' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "restore" ]]; then
    if [[ ${COMP_WORDS[2]} == "remote" ]]; then
      COMPREPLY=( $( compgen -W 'site repository config uploads database' -- $cur ) );
    else
      COMPREPLY=( $( compgen -W 'remote' -- $cur ) );
    fi
  else
    COMPREPLY=( $( compgen -W 'init import backup bootstrap restore clear commit check copy create add deploy change all' -- $cur ) );
  fi
}
complete -o nospace -F _poly_complete poly

