#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==================================================================================="
  echo "[help] ${path_this_script} [-p | --download-pkgs] [-b | --build]
                                   [-d | --dir_downloads] [-a | --dir_apps]
                                   [-n | --dir_bin] [-u | --user]"
  echo ""
  echo "       -p, --download_pkgs            download and install any missing pkgs"
  echo "       -b, --build                    desired build of neovim"
  echo "       -d, --dir_downloads            alternative downloads directory"
  echo "       -a, --dir_apps                 alternative apps directory"
  echo "       -n, --dir_bin                  alternative bin directory"
  echo "       -u, --user                     alternative user"
  echo "       -e, --set-editor               set editor"
  echo "==================================================================================="

}

# constants
NUM_POS_ARGS=0
NUM_OPT_ARGS=5
NUM_OPT_FLAGS=2
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
dir_downloads=""
dir_apps=""
dir_bin=""
user="${USER}"
set_editor=false

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
    -d | --dir_downloads)
      dir_downloads=$(readlink --canonicalize "${2}")
      shift 2
      ;;
    -a | --dir_apps)
      dir_apps=$(readlink --canonicalize "${2}")
      shift 2
      ;;
    -n | --dir_bin)
      dir_bin=$(readlink --canonicalize "${2}")
      shift 2
      ;;
    -u | --user)
      user=${2}
      shift 2
      ;;
    -e | --set-editor)
      set_editor=true
      shift 1
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
# set defaults
dir_home="/home/${user}"

if [ "${dir_downloads}" == "" ]; then
  dir_downloads=${dir_home}/downloads
fi

if [ "${dir_apps}" == "" ]; then
  dir_apps=${dir_home}/apps
fi

if [ "${dir_bin}" == "" ]; then
  dir_bin=${dir_home}/bin
fi

# check inputs
if [ "$EUID" -eq 0 ] && [ "$user" == "root" ]; then
  echo "[error] choose a user if running with sudo"
  exit 1
fi

if [[ "${user}" == "" ]]; then
  echo "[error] empty username"
  exit 1
fi

if ! id "${user}" >/dev/null 2>&1; then
  echo "[error] user ${user} not found."
  exit 1
fi

if [ ! -d "${dir_home}" ]; then
  echo "[error] ${dir_home} directory does not exist"
  exit 1
fi

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
rm -rf "${dir_bin}"/nvim
rm -rf "${dir_apps}"/nvim-"${nvim_build}"
tar -C "${dir_apps}" -xzf "${dir_downloads}"/nvim-"${nvim_build}".tar.gz
ln -s "${dir_apps}"/nvim-"${nvim_build}"/bin/nvim "${dir_bin}"/nvim
chown -R "${user}":"${user}" "${dir_downloads}/nvim-${nvim_build}.tar.gz" "${dir_apps}/nvim-${nvim_build}" "${dir_bin}/nvim"

# kickstart modular config
if [[ ! -d ${dir_home}/.config/nvim ]]; then

  if [[ ! -d ${dir_home}/.config ]]; then
    mkdir "${dir_home}"/.config -p
    chown -R "${user}":"${user}" "${dir_home}/.config"
  fi

  git clone https://github.com/dam9000/kickstart-modular.nvim "${dir_home}"/.config/nvim
  chown -R "${user}":"${user}" "${dir_home}/.config/nvim"
fi

if ${set_editor}; then

  file="${dir_home}/.bashrc"

  if [[ ! -f "${file}" ]]; then
    echo "[error] file does not exist."
    exit 1
  fi

  line="export EDITOR"

  if grep -qF -- "${line}" "${file}"; then
    sed -i "s|${line}=.*|${line}=${dir_home}/bin/nvim|" "${file}"
  else
    echo "${line}=${dir_home}/bin/nvim" >>"${file}"
  fi

fi

echo "[info] success"
