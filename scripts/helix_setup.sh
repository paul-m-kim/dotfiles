#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps

_helix_version='24.07'

wget -P $DOT_DIR_DOWNLOADS "https://github.com/helix-editor/helix/releases/download/${_helix_version}/helix-${_helix_version}-x86_64-linux.tar.xz" 
tar -xvf $DOT_DIR_DOWNLOADS/helix-${_helix_version}-x86_64-linux.tar.xz --directory $DOT_DIR_APPS/

cp $DOT_DIR_APPS/helix-${_helix_version}-x86_64-linux/hx $DOT_DIR_BIN/hx
cp -r $DOT_DIR_APPS/helix-${_helix_version}-x86_64-linux/runtime/ $HOME/.config/helix/ 

