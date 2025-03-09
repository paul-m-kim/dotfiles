#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "================"
  echo "- dir_downloads "
  echo "- dir_apps      "
  echo "- dir_bins      "
  echo "- zig_ver       "
  echo "================"

}

# constants
NUM_POS_ARGS=3
NUM_OPT_ARGS=2
NUM_OPT_FLAGS=0

declare -A DEPENDENCIES=(["wget"]="wget")

# runtime
path_this_script=${0}
dir_this_script="$(
  cd -- "$(dirname "${path_this_script}")" >/dev/null 2>&1
  pwd -P
)"

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
dir_downloads=${1%/}
dir_apps=${2%/}
dir_bin=${3%/}
shift ${NUM_POS_ARGS}

# optional - defaults
download_deps=false
zig_ver="0.14.0"

# optional
while (($# > 0)); do
  case $1 in
    -r | --version)
      zig_ver=$2
      shift 2
      ;;
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

# business
wget -nc -P "${dir_downloads}"/ https://ziglang.org/download/"${zig_ver}"/zig-linux-x86_64-"${zig_ver}".tar.xz
tar -C "${dir_apps}" -xf "${dir_downloads}"/zig-linux-x86_64-"${zig_ver}".tar.xz
rm -f "${dir_bin}"/zig
ln -s "${dir_apps}"/zig-linux-x86_64-"${zig_ver}"/zig "${dir_bin}"/zig

echo "[info] success"
