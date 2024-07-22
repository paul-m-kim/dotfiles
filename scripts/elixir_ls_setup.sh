#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps

_elixir_ls_version=v0.22.1

cd $DOT_DIR_DOWNLOADS
curl -fLO https://github.com/elixir-lsp/elixir-ls/releases/download/${_elixir_ls_version}/elixir-ls-${_elixir_ls_version}.zip
unzip -u elixir-ls-${_elixir_ls_version}.zip -d ${DOT_DIR_APPS}/elixir-ls
chmod +x ${DOT_DIR_APPS}/elixir-ls/language_server.sh
ln -s ${DOT_DIR_APPS}/elixir-ls/language_server.sh ${DOT_DIR_BIN}/elixir-ls

unset -v _elixir_ls_version

