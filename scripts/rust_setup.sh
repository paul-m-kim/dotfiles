#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

declare -a RUST_APPS=('cargo'
                      'rustc'
                      'rustup')

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

for APP in "${RUST_APPS[@]}"
do
  ln -s ${DOT_DIR_CARGO}/bin/${APP} ${DOT_DIR_BIN}/${APP}
done

