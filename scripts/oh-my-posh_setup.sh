#!/bin/bash

# environment variables
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${SCRIPTPATH}/../bash/.bashrc_ext

curl -s https://ohmyposh.dev/install.sh | bash -s

# by default, .bashrc is run before ~/bin is added to path
LINE='eval "$(~/bin/oh-my-posh init bash)"'
FILE="$HOME/.bashrc_ext"
grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"  
unset -v LINE FILE
