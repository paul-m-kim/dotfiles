#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==================================================================================="
  echo "[help] ${path_this_script} <dir_apps> <dir_bin> <pip_pkg_1> <pip_pkg_2> ..."
  echo ""
  echo "==================================================================================="

}

# constants
NUM_POS_ARGS=2
NUM_OPT_ARGS=0
NUM_OPT_FLAGS=0
NUM_EXT_ARGS_MAX=10

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

# args optional
while (($# > 0)); do
  case $1 in
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
dir_apps=$(readlink --canonicalize "${1}")
dir_bin=$(readlink --canonicalize "${2}")
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
if [ ! -d "${dir_apps}" ]; then
  echo "[error] ${dir_apps} directory does not exist"
  exit 1
fi

if [ ! -d "${dir_bin}" ]; then
  echo "[error] ${dir_bin} directory does not exist"
  exit 1
fi

# install pip packages
dir_python="${dir_apps}/python"

if [ ! -d "${dir_python}" ]; then
  echo "[info] creating ${dir_python} directory"
  mkdir -p "${dir_python}"
fi

python3 -m venv "${dir_python}"
. "${dir_python}/bin/activate"

for pip in "${args_extra[@]}"; do
  if [ "${pip}" != '' ] && [ ! "$(command -v "${pip}")" ] >/dev/null 2>&1; then
    echo "[info] pip package ${pip} not found"
    echo "[info] downloading ${pip}"
    pip3 install "${pip}"
    ln -s "${dir_python}"/bin/"${pip}" "${dir_bin}"/"${pip}"
  else
    echo "[info] pip package ${pip} already installed"
  fi
done

echo "[info] success"
