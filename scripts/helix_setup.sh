#!/bin/bash
HELIX_VERSION='24.07'

wget -P $DOT_DIR_DOWNLOADS "https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/helix-$HELIX_VERSION-x86_64-linux.tar.xz" 
tar -xvf $DOT_DIR_DOWNLOADS/helix-$HELIX_VERSION-x86_64-linux.tar.xz --directory $DOT_DIR_DOWNLOADS/

cp $DOT_DIR_DOWNLOADS/helix-$HELIX_VERSION-x86_64-linux/hx $DOT_DIR_BIN/hx
cp -r $DOT_DIR_DOWNLOADS/helix-$HELIX_VERSION-x86_64-linux/runtime/ $HOME/.config/helix/ 

