#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps
ZIG_VERSION=0.13.0

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
tar -C ${DOT_DIR_APPS} -xf ${DOT_DIR_DOWNLOADS}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz
ln -s ${DOT_DIR_APPS}/zig-linux-x86_64-${ZIG_VERSION}/zig ${DOT_DIR_BIN}/zig

