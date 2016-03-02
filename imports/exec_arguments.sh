#!/bin/bash
function exec_arguments {
  declare -a options=("${!1}")
  argument=${arguments[0]}

  if [ -z $argument ]; then
    select option in ${options[@]}
    do
      argument=$option
      break
    done
  fi

  containsElement "$argument" "${options[@]}"
  if [[ $? -eq 1 ]]; then
    arguments=("${arguments[@]:1}")
    exec_arguments options[@]
    return
  fi

  for option in ${options[@]}
  do
    if [[  $option -eq $argument ]]; then
      arguments=("${arguments[@]:1}")
      eval "$option"
      break
    fi
  done
}
function containsElement () { for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done; return 1; }
