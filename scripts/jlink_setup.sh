#!/bin/bash

set -e

print_help() {
  local path_this_script=${1}

  # https://en.wikipedia.org/wiki/Usage_message
  echo "==================================================================================="
  echo "[help] ${path_this_script} [-p | --download-pkgs] [-r | --version]
                                   [-d | --dir_downloads] [-a | --dir_apps]
                                   [-n | --dir_bin] [-u | --user]"
  echo ""
  echo "       -p, --download_pkgs            download and install any missing pkgs"
  echo "       -r, --version                  desired version"
  echo "       -d, --dir_downloads            alternative downloads directory"
  echo "       -a, --dir_apps                 alternative apps directory"
  echo "       -b, --dir_bin                  alternative bin directory"
  echo "       -u, --user                     alternative user"
  echo "==================================================================================="

}

# constants
NUM_POS_ARGS=0
NUM_OPT_ARGS=5
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
version='latest'
dir_downloads=""
dir_apps=""
dir_bin=""
user="${USER}"

# args optional
while (($# > 0)); do
  case $1 in
    -p | --download-pkgs)
      download_pkgs=true
      shift 1
      ;;
    -r | --version)
      version=${2}
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
pkg_name="jlink"
http_response_header="tmp_${pkg_name}_response_header.txt"

if [[ ${version} == 'latest' ]]; then
  curl -X POST https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.tgz -d "accept_license_agreement=accepted&submit=Download+software" --no-clobber -OJ --output-dir "${dir_downloads}" -D "${dir_downloads}/${http_response_header}"

  regex='filename="(.*)"'

  while IFS= read -r line; do
    if [[ $line =~ $regex ]]; then
      pkg_archive="${BASH_REMATCH[1]}"
      break
    fi
  done <"${dir_downloads}/${http_response_header}"

  rm -f "${dir_downloads}/${http_response_header}"
  pkg_filename="${pkg_archive%.*}"

else

  curl -X POST "https://www.segger.com/downloads/jlink/JLink_Linux_V${version}_x86_64.tgz" -d "accept_license_agreement=accepted&submit=Download+software" --no-clobber -OJ --output-dir "${dir_downloads}"

  pkg_filename="JLink_Linux_V${version}_x86_64"
  pkg_archive="${pkg_filename}.tgz"
fi

rm -rf "${dir_apps:?}/${pkg_name:?}"
mkdir -p "${dir_apps}/${pkg_name}"
tar -xvzf "${dir_downloads}/${pkg_archive}" --directory="${dir_apps}/${pkg_name}/"

for path_abs_app in "${dir_apps}"/"${pkg_name}"/"${pkg_filename}"/JLink*Exe; do
  app=$(basename "${path_abs_app%Exe}")
  rm -f "${dir_bin}/${app}"
  ln -s "${path_abs_app}" "${dir_bin}/${app}"
done

if [ "$EUID" -eq 0 ]; then
  sudo cp "${dir_apps}/${pkg_filename}/99-jlink.rules" /etc/udev/rules.d/
  sudo udevadm control -R
  sudo udevadm trigger --action=remove --attr-match=idVendor=1366 --subsystem-match=usb
  sudo udevadm trigger --action=add --attr-match=idVendor=1366 --subsystem-match=usb
else

  cat <<EOF
run the following in sudo:
sudo cp "${dir_apps}/${pkg_name}/${pkg_filename}/99-jlink.rules" /etc/udev/rules.d/
sudo udevadm control -R
sudo udevadm trigger --action=remove --attr-match=idVendor=1366 --subsystem-match=usb
sudo udevadm trigger --action=add --attr-match=idVendor=1366 --subsystem-match=usb
EOF

fi
