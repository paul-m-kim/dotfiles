
#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

wget -nc -P ${DOT_DIR_DOWNLOADS}/ https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
unzip -u ${DOT_DIR_DOWNLOADS}/ninja-linux.zip -d ${DOT_DIR_APPS}/ninja
ln -s ${DOT_DIR_APPS}/ninja/ninja ${DOT_DIR_BIN}/ninja
