#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==================================================================================="
  echo "[help] ${path_this_script} [-p | --download-pkgs]
                                   <dir_downloads> <dir_apps> <dir_bin>"
  echo ""
  echo "       -p, --download_pkgs            download and install any missing pkgs"
  echo "==================================================================================="

}

# constants
NUM_POS_ARGS=3
NUM_OPT_ARGS=0
NUM_OPT_FLAGS=1
NUM_EXT_ARGS_MAX=0

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
if (($# < NUM_POS_ARGS)) || (($# > (NUM_POS_ARGS + (NUM_OPT_ARGS * 2) + NUM_OPT_FLAGS + NUM_EXT_ARGS_MAX))); then
  echo "[error] invalid number of arguments"
  print_help "${path_this_script}"
  exit 1
fi

# args optional - defaults
download_pkgs=false
nvim_build="linux-x86_64"

# args optional
while (($# > 0)); do
  case $1 in
    -p | --download-pkgs)
      download_pkgs=true
      shift 1
      ;;
    -b | --build)
      nvim_build=${2}
      shift 2
      ;;
    -*)
      echo "[error] ${1} is an invalid option"
      print_help "${path_this_script}"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# args positional

# relative path to absolute path
# path_abs=$(readlink --canonicalize ${path})
# path_abs=$(cd ${path}; pwd)
dir_downloads=$(readlink --canonicalize "${1}")
dir_apps=$(readlink --canonicalize "${2}")
dir_bin=$(readlink --canonicalize "${3}")
shift ${NUM_POS_ARGS}

# args optional and extra
if (($# > NUM_EXT_ARGS_MAX)); then
  echo "[error] there are too many extra arguments"
  exit 1
else
  declare -a args_extra=()
  while (($# > 0)); do
    args_extra+=("${1}")
    shift 1
  done
fi

# business
# check directories
if [ ! -d "${dir_downloads}" ]; then
  echo "[error] ${dir_downloads} directory does not exist"
  exit 1
fi

if [ ! -d "${dir_apps}" ]; then
  echo "[error] ${dir_apps} directory does not exist"
  exit 1
fi

if [ ! -d "${dir_bin}" ]; then
  echo "[error] ${dir_bin} directory does not exist"
  exit 1
fi

# https://github.com/neovim/neovim/blob/master/INSTALL.md
wget -nc -P "${dir_downloads}" https://github.com/neovim/neovim/releases/latest/download/nvim-"${nvim_build}".tar.gz
rm "${dir_bin}"/nvim
rm -rf "${dir_apps}"/nvim-"${nvim_build}"
tar -C "${dir_apps}" -xzf "${dir_downloads}"/nvim-"${nvim_build}".tar.gz
ln -s "${dir_apps}"/nvim-"${nvim_build}"/bin/nvim "${dir_bin}"/nvim

# kickstart modular config
if [[ ! -d ${HOME}/.config/nvim ]]; then
  mkdir "${HOME}"/.config -p
  git clone https://github.com/dam9000/kickstart-modular.nvim "${HOME}"/.config/nvim
fi

echo "[info] success"
