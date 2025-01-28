#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

# prerequisite
. ${SCRIPTPATH}/nodejs_setup.sh
. ${SCRIPTPATH}/python_setup.sh

declare -a PIP_BINS=('yamllint' \
                     'ansible-lint')

sudo npm i -g @ansible/ansible-language-server

. ${DOT_DIR_PYTHON_VENV}/bin/activate

pip3 install yamllint ansible-dev-tools

for _bin in "${PIP_BINS[@]}"
do
  ln -s ${DOT_DIR_PYTHON_VENV}/bin/${_bin} ${DOT_DIR_BIN}/${_bin}
done
