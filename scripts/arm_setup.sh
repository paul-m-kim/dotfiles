#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
tar -C ${DOT_DIR_APPS} -xf ${DOT_DIR_DOWNLOADS}/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
ln -s ${DOT_DIR_APPS}/gcc-arm-none-eabi-10.3-2021.10/bin/* ${DOT_DIR_BIN}/
