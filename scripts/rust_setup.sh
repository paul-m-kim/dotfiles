#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps
DOT_DIR_CARGO=${DOT_DIR_APPS}/cargo
DOT_DIR_RUSTUP=${DOT_DIR_APPS}/rustup

export RUSTUP_HOME=${DOT_DIR_RUSTUP}
export CARGO_HOME=${DOT_DIR_CARGO}

declare -a RUST_APPS=('cargo'
                      'rustc'
                      'rustup')

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

for APP in "${RUST_APPS[@]}"
do
  ln -s ${DOT_DIR_CARGO}/bin/${APP} ${DOT_DIR_BIN}/${APP}
done

