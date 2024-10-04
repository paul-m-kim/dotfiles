#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://github.com/Kitware/CMake/releases/download/v3.30.4/cmake-3.30.4-linux-x86_64.tar.gz
tar -C ${DOT_DIR_APPS} -xzf ${DOT_DIR_DOWNLOADS}/cmake-3.30.4-linux-x86_64.tar.gz
ln -s ${DOT_DIR_APPS}/cmake-3.30.4-linux-x86_64/bin/* ${DOT_DIR_BIN}/
