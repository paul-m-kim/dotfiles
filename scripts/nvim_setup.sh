#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

# https://github.com/neovim/neovim/blob/master/INSTALL.md
NEOVIM_BUILD="nvim-linux64"

wget -nc -P ${DOT_DIR_DOWNLOADS} https://github.com/neovim/neovim/releases/latest/download/${NEOVIM_BUILD}.tar.gz
rm -rf ${DOT_DIR_APPS}/${NEOVIM_BUILD}
rm ${DOT_DIR_BIN}/nvim
tar -C ${DOT_DIR_APPS} -xzf ${DOT_DIR_DOWNLOADS}/${NEOVIM_BUILD}.tar.gz
ln -s ${DOT_DIR_APPS}/${NEOVIM_BUILD}/bin/nvim ${DOT_DIR_BIN}/nvim
