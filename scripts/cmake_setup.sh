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
  echo "       -e, --set-editor               set editor"
  echo "==================================================================================="

}

# constants
readonly NUM_POS_ARGS=0
readonly NUM_OPT_ARGS=7
readonly NUM_OPT_FLAGS=1
readonly NUM_EXT_ARGS_MAX=0

target=$(uname -m)
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
version='latest'
target=${target,,}
os=${os,,}
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
    -t | --target)
      target=${2}
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
target_text=''

case "${os}" in
  windows)
    case "${target}" in
      x86)
        err "not available"
        ;;
      x86_64)
        err "not available"
        ;;
      aarch32)
        err "not available"
        ;;
      aarch64)
        err "not available"
        ;;
      *)
        err "not available"
        ;;
    esac
    pkg_compression=''
    err "not supported in script"
    ;;
  darwin)
    case "${target}" in
      x86)
        target_text='macos-universal'
        ;;
      x86_64)
        target_text='macos-universal'
        ;;
      aarch32)
        target_text='macos-universal'
        ;;
      aarch64)
        target_text='macos-universal'
        ;;
      *)
        err "not available"
        ;;
    esac
    pkg_compression='tar.gz'
    ;;
  linux)
    case "${target}" in
      x86)
        err "not available"
        ;;
      x86_64)
        target_text='linux-x86_64'
        ;;
      aarch32)
        err "not available"
        ;;
      aarch64)
        target_text='linux-aarch64'
        ;;
      *)
        err "not available"
        ;;
    esac
    pkg_compression='tar.gz'
    ;;
  *)
    err "not supported"
    ;;
esac

github_root='Kitware'
github_repo='CMake'
github_base_url="https://github.com/${github_root}/${github_repo}/releases"
github_latest_url="${github_base_url}/latest"

if [ "${version}" == 'latest' ]; then
  latest_release_url_header=$(curl --head "${github_latest_url}" | grep location)
  regex_get_release="^location:.+/tag/([0-9a-zA-Z.-]+)\s*$"
  if [[ $latest_release_url_header =~ $regex_get_release ]]; then
    version="${BASH_REMATCH[1]}"
    echo "[info] using the latest verion: $version"
  else
    echo "[error] failed to get latest version."
    exit 1
  fi

fi

regex_get_version="^v([0-9.-]+)\s*$"
if [[ $version =~ $regex_get_version ]]; then
  version_numerals="${BASH_REMATCH[1]}"
  echo "[info] version numerals: $version_numerals"
fi

github_version_url="${github_base_url}/download/${version}"
pkg_name="cmake"
pkg_bin=""
pkg_filename="${pkg_name}-${version_numerals}-${target_text}"
pkg_archive="${pkg_filename}.${pkg_compression}"

wget -nc -P "${dir_downloads}" "${github_version_url}/${pkg_archive}"
rm -rf "${dir_apps:?}/${pkg_name:?}"
mkdir -p "${dir_apps}/${pkg_name}"
tar -xvzf "${dir_downloads}/${pkg_archive}" --directory="${dir_apps}/${pkg_name}/"

if [[ -n "${pkg_bin}" ]]; then

  rm -f "${dir_bin}/${pkg_bin}"
  ln -s "${dir_apps}/${pkg_name,,}/${pkg_filename}/bin/${pkg_bin}" "${dir_bin}/${app}"

else

  apps=$(ls "${dir_apps}/${pkg_name,,}/${pkg_filename}/bin/")

  for app in ${apps}; do
    rm -f "${dir_bin}/${app}"
    ln -s "${dir_apps}/${pkg_name,,}/${pkg_filename}/bin/${app}" "${dir_bin}/${app}"
  done

fi
