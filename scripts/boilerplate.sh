#!/bin/bash

# todo:
# - fully support usage format:
#   - https://en.wikipedia.org/wiki/Usage_message
#   - https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html#tag_12_01
#   - https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/command-line-syntax-key

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

print_examples() {
  echo "==================================================================================="
  echo "[help] some examples:"
  echo ""
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

declare -a argv_rem

# help
if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
  print_help "${path_this_script}"
  exit 0
fi

# examples
if [[ "${1}" == "--examples" ]]; then
  print_examples
  exit 0
fi

# check number of arguments
if (($# < NUM_POS_ARGS)) || (($# > (NUM_POS_ARGS + (NUM_OPT_ARGS * 2) + NUM_OPT_FLAGS))); then
  echo "[error] invalid number of arguments"
  print_help "${path_this_script}"
  exit 1
fi

# args optional - defaults
opts_end=false

# args optional labelled
function fn_opts_parse() {

  while (($# > 0)); do
    case $1 in
      --)
        opts_end=true
        shift 1
        break
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

}

fn_opts_parse "$@"
set -- "${argv_rem[@]}"

# args positional
if (($# < NUM_POS_ARGS)); then
  echo "[error] not enough positional arguments."
  exit 1
fi

shift ${NUM_POS_ARGS}

# args optional - defaults

# args optional trailing
if ! ${opts_end}; then
  fn_opts_parse "$@"
  set -- "${argv_rem[@]}"
fi

# business
echo "[info] success"
