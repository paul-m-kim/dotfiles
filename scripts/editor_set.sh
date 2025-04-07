#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "[error] sudo needed"
  exit 1
fi

user=${1}
app=${2}
dir_home="/home/${user}"

if [[ ! -f /etc/sudoers.d/50-editor ]]; then

  sudo tee /etc/sudoers.d/50-editor >/dev/null <<'EOF'
# This allows running arbitrary commands, but so does ALL, and it means
# different sudoers have their choice of editor respected.
Defaults:%sudo env_keep += "EDITOR"
EOF

fi

if [[ "${user}" != "" ]] && [[ "${app}" != "" ]]; then

  file="${dir_home}/.bashrc_ext"

  if [[ ! -f "${file}" ]]; then
    echo "[error] file does not exist."
    exit 1
  fi

  line="export EDITOR"

  if grep -qF -- "${line}" "${file}"; then
    sed -i "s|${line}=.*|${line}=${dir_home}/bin/${app}|" "${file}"
  else
    echo "${line}=${dir_home}/bin/${app}" >>"${file}"
  fi

fi
