#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps
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

unset -v DOT_DIR_PYTHON_VENV PIP_PACKAGES _package

