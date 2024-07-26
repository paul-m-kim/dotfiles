#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://github.com/zigtools/zls/releases/latest/download/zls-x86_64-linux.tar.xz
mkdir -p ${DOT_DIR_APPS}/zls
tar -C ${DOT_DIR_APPS}/zls -xf ${DOT_DIR_DOWNLOADS}/zls-x86_64-linux.tar.xz
ln -s ${DOT_DIR_APPS}/zls/zls ${DOT_DIR_BIN}/zls

