# bash completion for the `poly` command

_poly_complete() {
  local cur
  # Pointer to current completion word.
  # By convention, it's named "cur" but this isn't strictly necessary.
  cur=${COMP_WORDS[COMP_CWORD]}
  if [[ ${COMP_WORDS[1]} == "import" ]]; then
    COMPREPLY=( $( compgen -W 'local-database-to-remote remote-database-to-local' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "backup" ]]; then
    COMPREPLY=( $( compgen -W 'remote-sites' -- $cur ) );
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
  elif [[ ${COMP_WORDS[1]} == "create" ]]; then
    COMPREPLY=( $( compgen -W 'gh-pages' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "export" ]]; then
    COMPREPLY=( $( compgen -W 'local-database remote-database' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "add" ]]; then
    COMPREPLY=( $( compgen -W 'custom-post-types taxonomies' -- $cur ) );
  elif [[ ${COMP_WORDS[1]} == "deploy" ]]; then
    COMPREPLY=( $( compgen -W 'stage production' -- $cur ) );
  else
    COMPREPLY=( $( compgen -W 'init import backup copy create add deploy' -- $cur ) );
  fi
}
complete -o nospace -F _poly_complete poly

