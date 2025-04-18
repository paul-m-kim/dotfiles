#!/bin/bash

# docs:
# https://man7.org/linux/man-pages/man1/hostnamectl.1.html
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/networking_guide/sec_configuring_host_names_using_hostnamectl

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

# constants
NUM_POS_ARGS=1
NUM_OPT_ARGS=3
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
prefix=""
postfix=""
delim=''

# args optional labelled
while (($# > 0)); do
  case $1 in
    -e | --prefix)
      prefix=${2}
      shift 2
      ;;
    -t | --postfix)
      postfix=${2}
      shift 2
      ;;
    -d | --deliminator)
      delim=${2}
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
hostname=${1}
shift ${NUM_POS_ARGS}

# args optional - defaults

# args optional labelled
while (($# > 0)); do
  case $1 in
    *)
      echo "[error] ${1} is an invalid option"
      print_help "${path_this_script}"
      exit 1
      ;;
  esac
done

# business
hostname_old=$(hostname)

if [[ ${hostname} == "" ]]; then
  echo "[error] new hostname cannot be empty."
  exit 1
fi

# option dmidecode:
# hostname=$(sudo dmidecode -s system-serial-number)

hostname_lower=$(echo "${hostname}" | tr '[:upper:]' '[:lower:]')
hostname_new="${prefix}${delim}${hostname_lower}${delim}${postfix}"

echo "[info] new hostname: ${hostname_new}"
sudo hostnamectl set-hostname "${hostname_new}" --static

# https://askubuntu.com/questions/76808/how-do-i-use-variables-in-a-sed-command
sudo sed -i "s/${hostname_old}/${hostname_new}/g" /etc/hosts

echo "[info] success"
