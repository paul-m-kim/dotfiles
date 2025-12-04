#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==================================================================================="
  echo "[help] ${path_this_script} [-p | --download-pkgs] [-r | --version]
                                   [-d | --dir_downloads] [-a | --dir_apps]
                                   [-b | --dir_bin] <user>"
  echo ""
  echo "       -p, --download_pkgs            download and install any missing pkgs"
  echo "       -r, --version                  desired version"
  echo "       -t, --target                   desired target"
  echo "       -o, --os                       desired os"
  echo "       -d, --dir_downloads            alternative downloads directory"
  echo "       -a, --dir_apps                 alternative apps directory"
  echo "       -b, --dir_bin                  alternative bin directory"
  echo "       -u, --user                     alternative user"
  echo "       -l, --toolchain                arm toolchain (gcc?/gnu?)"
  echo "==================================================================================="

}

# constants
readonly NUM_POS_ARGS=0
readonly NUM_OPT_ARGS=8
readonly NUM_OPT_FLAGS=1
readonly NUM_EXT_ARGS_MAX=0

os_target=$(uname -m)
os=$(uname)

# runtime
path_this_script=${0}
if [ -f "${path_this_script}" ]; then
  dir_this_script="$(
    cd -- "$(dirname "${path_this_script}")" || return >/dev/null 2>&1
    pwd -P
  )"
fi

source "${dir_this_script}/common.sh"

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
release=''
os_target=${os_target,,}
os=${os,,}
dir_downloads=""
dir_apps=""
dir_bin=""
user="${USER}"
arm_toolchain='arm-gcc'

# args optional
while (($# > 0)); do
  case $1 in
    -p | --download-pkgs)
      download_pkgs=true
      shift 1
      ;;
    -r | --version)
      release=${2}
      shift 2
      ;;
    -t | --target)
      os_target=${2}
      shift 2
      ;;
    -o | --os)
      os=${2}
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
    -b | --dir_bin)
      dir_bin=$(readlink --canonicalize "${2}")
      shift 2
      ;;
    -u | --user)
      user=${2}
      shift 2
      ;;
    -l | --toolchain)
      arm_toolchain=${2}
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

# business
if [ -z "${release}" ]; then
  err "release needs to be specified."
else
  version="${release}"
fi

# supported targets:
# - arm-gcc (prefix='gcc-arm-none-eabi')
#   -  win32
#   -  x86_64-linux
#   -  aarch64-linux
#   -  mac
# - arm-gnu (prefix='arm-gnu-toolchain')
#   -  windows x86 (mingw-w64-i686)
#      -  arm-none-eabi
#      -  arm-none-linux-gnueabihf
#      -  aarch64-none-elf
#      -  aarch64-none-linux-gnu
#   -  windows x86_64 (mingw-w64-x86_64)
#      -  arm-none-eabi
#      -  arm-none-linux-gnueabihf
#      -  aarch64-none-elf
#      -  aarch64-none-linux-gnu
#   -  linux x86_64 (x86_64)
#      -  arm-none-eabi
#      -  arm-none-linux-gnueabihf
#      -  aarch64-none-elf
#      -  aarch64-none-linux-gnu
#      -  aarch64_be-none-linux-gnu
#   -  linux aarch64 (aarch64)
#      -  arm-none-eabi
#      -  arm-none-linux-gnueabihf
#      -  aarch64-none-elf
#      -  aarch64-none-linux-gnu
#   -  darwin aarch64 (darwin-arm64)
#      -  arm-none-eabi
#      -  aarch64-none-elf

target_text=''
arm_toolchain='arm_gcc'
arm_target='arm-none-eabi'

case "${arm_toolchain}" in
  arm_gcc)
    case "${os}" in
      windows)
        case "${os_target}" in
          x86)
            target_text="win32"
            ;;
          *)
            err "not available"
            ;;
        esac
        pkg_compression='zip'
        err "not supported in script"
        ;;
      darwin)
        case "${os_target}" in
          *)
            target_text="mac"
            ;;
        esac
        pkg_compression='tar.bz2'
        ;;
      linux)
        case "${os_target}" in
          x86_64)
            target_text="x86_64-linux"
            ;;
          aarch64)
            target_text="aarch64-linux"
            ;;
          *)
            err "not available"
            ;;
        esac
        pkg_compression='tar.bz2'
        ;;
      *)
        err "not supported"
        ;;
    esac
    ;;
  arm_gnu)
    case "${os}" in
      windows)
        pkg_compression='zip'
        case "${os_target}" in
          x86)
            case "${arm_target}" in
              arm-none-eabi)
                target_text="mingw-w64-i686-${arm_target}"
                ;;
              arm-none-linux-gnueabihf)
                target_text="mingw-w64-i686-${arm_target}"
                ;;
              aarch64-none-elf)
                target_text="mingw-w64-i686-${arm_target}"
                ;;
              aarch64-none-linux-gnu)
                target_text="mingw-w64-i686-${arm_target}"
                ;;
              *)
                err "not supported arm target."
                ;;
            esac
            ;;
          x86_64)
            case "${arm_target}" in
              arm-none-eabi)
                target_text="mingw-w64-x86_64-${arm_target}"
                ;;
              arm-none-linux-gnueabihf)
                target_text="mingw-w64-x86_64-${arm_target}"
                ;;
              aarch64-none-elf)
                target_text="mingw-w64-x86_64-${arm_target}"
                ;;
              aarch64-none-linux-gnu)
                target_text="mingw-w64-x86_64-${arm_target}"
                ;;
              *)
                err "not supported arm target."
                ;;
            esac
            ;;
          *)
            err "not available"
            ;;
        esac
        err "not supported in script"
        ;;
      darwin)
        pkg_compression='tar.xz'
        case "${os_target}" in
          aarch64)
            case "${arm_target}" in
              arm-none-eabi)
                target_text="darwin-arm64-${arm_target}"
                ;;
              aarch64-none-elf)
                target_text="darwin-arm64-${arm_target}"
                ;;
              *)
                err "not supported arm target."
                ;;
            esac
            ;;
          *)
            err "not available"
            ;;
        esac
        ;;
      linux)
        pkg_compression='tar.xz'
        case "${os_target}" in
          x86_64)
            case "${arm_target}" in
              arm-none-eabi)
                target_text="${os_target}-${arm_target}"
                ;;
              arm-none-linux-gnueabihf)
                target_text="${os_target}-${arm_target}"
                ;;
              aarch64-none-elf)
                target_text="${os_target}-${arm_target}"
                ;;
              aarch64-none-linux-gnu)
                target_text="${os_target}-${arm_target}"
                ;;
              aarch64_be-none-linux-gnu)
                command ...
                ;;
              *)
                err "not supported arm target."
                ;;
            esac
            ;;
          aarch64)
            case "${arm_target}" in
              arm-none-eabi)
                target_text="${os_target}-${arm_target}"
                ;;
              arm-none-linux-gnueabihf)
                target_text="${os_target}-${arm_target}"
                ;;
              aarch64-none-elf)
                target_text="${os_target}-${arm_target}"
                ;;
              aarch64-none-linux-gnu)
                target_text="${os_target}-${arm_target}"
                ;;
              *)
                err "not supported arm target."
                ;;
            esac
            ;;
          *)
            err "not available"
            ;;
        esac
        ;;
      *)
        err "not supported"
        ;;
    esac
    ;;
  *)
    err "not supported arm toolchain"
    ;;
esac

case "${arm_toolchain}" in
  arm_gcc)
    arm_developer_base_url="https://developer.arm.com/-/media/files/downloads/gnu-rm/"
    arm_version_url="${arm_developer_base_url}/${version}"
    pkg_name="gcc-arm-none-eabi"
    ;;
  arm_gnu)
    arm_developer_base_url="https://developer.arm.com/-/media/files/downloads/gnu/"
    arm_version_url="${arm_developer_base_url}/${version}/binrel"
    pkg_name="arm-gnu-toolchain"
    ;;
  *)
    command ...
    ;;
esac

pkg_bin=""

pkg_filename_has_version=true
if [ "${pkg_filename_has_version}" = true ]; then
  pkg_filename="${pkg_name}-${version}-${target_text}"
else
  pkg_filename="${pkg_name}-${target_text}"
fi
pkg_archive="${pkg_filename}.${pkg_compression}"
pkg_content="${pkg_name}-${version}"

wget -nc -P "${dir_downloads}" "${arm_version_url}/${pkg_archive}"
rm -rf "${dir_apps:?}/${pkg_name:?}"
mkdir -p "${dir_apps}/${pkg_name}"

case "${pkg_compression}" in
  'zip')
    unzip -u "${dir_downloads}/${pkg_archive}" -d "${dir_apps}/${pkg_name}"
    ;;
  'tar.xz' | 'tar.gz')
    tar -xvzf "${dir_downloads}/${pkg_archive}" --directory="${dir_apps}/${pkg_name}/"
    ;;
  tar.bz2)
    tar -xvjf "${dir_downloads}/${pkg_archive}" --directory="${dir_apps}/${pkg_name}/"
    ;;
  *)
    err "unsupported compression."
    ;;
esac

if [[ -n "${pkg_bin}" ]]; then

  rm -f "${dir_bin}/${pkg_bin}"
  ln -s "${dir_apps}/${pkg_name,,}/${pkg_content}/${pkg_bin}" "${dir_bin}/${app}"

else

  apps=$(ls "${dir_apps}/${pkg_name,,}/${pkg_content}/bin/")

  for app in ${apps}; do
    rm -f "${dir_bin}/${app}"
    ln -s "${dir_apps}/${pkg_name,,}/${pkg_content}/bin/${app}" "${dir_bin}/${app}"
  done

fi
