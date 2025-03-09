#!/bin/bash

set -e

print_help() {
  local path_this_Script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==========="
  echo "           "
  echo "           "
  echo "           "
  echo "           "
  echo "==========="

}

# constants
NUM_POS_ARGS=0
NUM_OPT_ARGS=0
NUM_OPT_FLAGS=0

declare -A DEPENDENCIES=(["echo"]="echo")

# runtime
path_this_script=${0}
dir_this_script="$( cd -- "$(dirname "${path_this_script}")" >/dev/null 2>&1 ; pwd -P )"

# help
if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
  print_help "${path_this_script}"
  exit 0
fi

# check number of arguments
if (($# < NUM_POS_ARGS)) || (($# > (NUM_POS_ARGS + (NUM_OPT_ARGS * 2) + NUM_OPT_FLAGS))); then
  echo "[error] invalid number of arguments"
  print_help "${path_this_sript}"
  exit 1
fi

# positional
shift ${NUM_POS_ARGS}

# optional - defaults

# optional
while (($# > 0)); do
  case $1 in
    *)
      echo "[error] ${1} is an invalid option"
      print_help "${path_this_script}"
      exit
      ;;
  esac
done

# check dependencies
for cmd in "${!DEPENDENCIES[@]}"; do
  if [ "${cmd}" != '' ] && [ ! "$(command -v "${cmd}")" ] >/dev/null 2>&1; then
    if ${download_deps}; then
      echo "[info] dependency ${DEPENDENCIES["${cmd}"]} not found"
      if [ "$EUID" - ne 0 ]; then
        echo "[error] run this script in sudo to install missing deps"
        exit 1
      else
        echo "[info] downloading ${DEPENDENCIES["${cmd}"]}"
        sudo apt install "${DEPENDENCIES["${cmd}"]}" -y
      fi
    else
      echo "[error] dependency ${DEPENDENCIES["${cmd}"]} not found"
      exit 1
    fi
  fi
done

# business

echo "[info] success"
