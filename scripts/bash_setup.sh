#!/bin/bash

# environment variables
SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"
. ${SCRIPTPATH}/../bash/.bashrc_ext

LINE='. "$HOME/.bashrc_ext"'
FILE="$HOME/.bashrc"
grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >>"$FILE"
unset -v LINE FILE

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://github.com/patrickvane/shfmt/releases/download/master/shfmt_linux_amd64
mv ${DOT_DIR_DOWNLOADS}/shfmt_linux_amd64 ${DOT_DIR_APPS}/shfmt
chmod +x ${DOT_DIR_APPS}/shfmt
ln -s ${DOT_DIR_APPS}/shfmt ${DOT_DIR_BIN}/shfmt

sudo apt install shellcheck
