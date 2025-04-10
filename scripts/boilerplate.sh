#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==================================================================================="
  echo "[help] ${path_this_script} [-abcd...] [--golf] [-e | -f] [[-h | --hotel] <value>]
                                   <arg_pos_1> <arg_pos_2> ...
                                   [-ijkl...] [--mike] [-n | -o] [[-p | --papa] <value>]"
  echo ""
  echo "       -a, --alpha                    optional flag alpha"
  echo "       ..."
  echo "       -h, --hotel <val_hotel>        optional argument hotel"
  echo "       ..."
  echo "==================================================================================="

}

# constants
NUM_POS_ARGS=0
NUM_OPT_ARGS=0
NUM_OPT_FLAGS=0

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

# args optional - defaults

# args optional labelled
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
shift ${NUM_POS_ARGS}

# args optional - defaults

# args optional labelled
while (($# > 0)); do
  case $1 in
    -*)
      echo "[error] ${1} is an invalid option"
      print_help "${path_this_script}"
      exit 1
      ;;
  esac
done

# business
echo "[info] success"
