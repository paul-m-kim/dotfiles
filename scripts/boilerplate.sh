#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "================"
  echo "- dir_downloads "
  echo "- dir_apps      "
  echo "- dir_bins      "
  echo "-               "
  echo "================"

}

# constants
NUM_POS_ARGS=3
NUM_OPT_ARGS=1
NUM_OPT_FLAGS=0

declare -A DEPENDENCIES=(["echo"]="echo")

# runtime
path_this_script=${0}
if [ -f "${path_this_script}" ]; then
  dir_this_script="$(
    cd -- "$(dirname "${path_this_script}")" || return >/dev/null 2>&1
    pwd -P
  )"
fi

# help
if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
  print_help "${path_this_script}"
  exit 0
fi

# check number of arguments
if (($# < NUM_POS_ARGS)) || (($# > (NUM_POS_ARGS + (NUM_OPT_ARGS * 2) + NUM_OPT_FLAGS))); then
  echo "[error] invalid number of arguments"
  print_help "${path_this_script}"
  exit 1
fi

# positional

# relative path to absolute path
# path_abs=$(readlink --canonicalize ${path})
# path_abs=$(cd ${path}; pwd)
dir_downloads=$(readlink --canonicalize "${1}")
dir_apps=$(readlink --canonicalize "${2}")
dir_bin=$(readlink --canonicalize "${3}")
shift ${NUM_POS_ARGS}

# optional - defaults
download_deps=false

# optional
while (($# > 0)); do
  case $1 in
    -p | --download-deps)
      download_deps=true
      shift 1
      ;;
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
      if [ "$EUID" -ne 0 ]; then
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

# create directories
if [ ! -d "${dir_downloads}" ]; then
  mkdir -p "${dir_downloads}"
fi

if [ ! -d "${dir_apps}" ]; then
  mkdir -p "${dir_apps}"
fi

if [ ! -d "${dir_bin}" ]; then
  mkdir -p "${dir_bin}"
fi

# business

echo "[info] success"
