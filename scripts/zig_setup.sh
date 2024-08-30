#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

ZIG_VERSION=0.13.0

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
tar -C ${DOT_DIR_APPS} -xf ${DOT_DIR_DOWNLOADS}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
ln -s ${DOT_DIR_APPS}/zig-linux-x86_64-${ZIG_VERSION}/zig ${DOT_DIR_BIN}/zig

