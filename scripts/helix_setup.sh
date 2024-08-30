#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

_helix_version='24.07'

wget -nc -P $DOT_DIR_DOWNLOADS "https://github.com/helix-editor/helix/releases/download/${_helix_version}/helix-${_helix_version}-x86_64-linux.tar.xz" 
tar -xvf $DOT_DIR_DOWNLOADS/helix-${_helix_version}-x86_64-linux.tar.xz --directory $DOT_DIR_APPS/

if [ ! -d "$HOME/.config/helix" ]; then
  mkdir -p "$HOME/.config/helix"
fi

ln -s $DOT_DIR_APPS/helix-${_helix_version}-x86_64-linux/runtime/ $HOME/.config/helix/runtime 
ln -s $DOT_DIR_APPS/helix-${_helix_version}-x86_64-linux/hx $DOT_DIR_BIN/hx

