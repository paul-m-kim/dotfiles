#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

# prerequisite
. ${SCRIPTPATH}/nodejs_setup.sh

sudo npm i -g yaml-language-server@next
