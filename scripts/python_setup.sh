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

declare -A PACKAGES_APT=(["echo"]="echo")
declare -A PACKAGES_PIP=(["black"]="black" ["ruff-lsp"]="ruff-lsp")

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
download_pkgs=false

# optional
while (($# > 0)); do
  case $1 in
    -p | --download-pkgs)
      download_pkgs=true
      shift 1
      ;;
    *)
      echo "[error] ${1} is an invalid option"
      print_help "${path_this_script}"
      exit
      ;;
  esac
done

# create directories
if [ ! -d "${dir_downloads}" ]; then
  exit 1
  # mkdir -p "${dir_downloads}"
fi

if [ ! -d "${dir_apps}" ]; then
  exit 1
  # mkdir -p "${dir_apps}"
fi

if [ ! -d "${dir_bin}" ]; then
  exit 1
  # mkdir -p "${dir_bin}"
fi

if [ ! -d "${dir_bin}" ]; then
  exit 1
  # mkdir -p "${dir_bin}"
fi

# install apt packages
for cmd in "${!PACKAGES_APT[@]}"; do
  if [ "${cmd}" != '' ] && [ ! "$(command -v "${cmd}")" ] >/dev/null 2>&1; then
    if ${download_pkgs}; then
      echo "[info] apt package ${PACKAGES_APT["${cmd}"]} not found"
      if [ "$EUID" -ne 0 ]; then
        echo "[error] run this script in sudo to install missing apt packages"
        exit 1
      else
        echo "[info] downloading ${PACKAGES_APT["${cmd}"]}"
        sudo apt install "${PACKAGES_APT["${cmd}"]}" -y
      fi
    else
      echo "[error] apt package ${PACKAGES_APT["${cmd}"]} not found"
      exit 1
    fi
  fi
done

# install pip packages
dir_python="${dir_apps}/python"

if [ ! -d "${dir_python}" ]; then
  mkdir -p "${dir_python}"
else
  python3 -m venv "${dir_python}"
  . "${dir_python}/bin/activate"
fi

for cmd in "${!PACKAGES_PIP[@]}"; do
  if [ "${cmd}" != '' ] && [ ! "$(command -v "${cmd}")" ] >/dev/null 2>&1; then
    if ${download_pkgs}; then
      echo "[info] pip package ${PACKAGES_PIP["${cmd}"]} not found"
      echo "[info] downloading ${PACKAGES_PIP["${cmd}"]}"
      pip3 install "${PACKAGES_PIP["${cmd}"]}"
      ln -s "${dir_python}"/bin/"${cmd}" "${dir_bin}"/"${cmd}"
    else
      echo "[error] pip package ${PACKAGES_APT["${cmd}"]} not found"
      exit 1
    fi
  fi
done

# business
echo "[info] success"
