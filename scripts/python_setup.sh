#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

DOT_DIR_PYTHON_VENV=${DOT_DIR_APPS}/python
declare -a PIP_PACKAGES=('ruff-lsp' \
                         'black')

python3 -m venv ${DOT_DIR_PYTHON_VENV}
. ${DOT_DIR_PYTHON_VENV}/bin/activate

pip3 install ${PIP_PACKAGES}

for _package in "${PIP_PACKAGES[@]}"
do
  ln -s ${DOT_DIR_PYTHON_VENV}/bin/${_package} ${DOT_DIR_BIN}/${_package}
done

