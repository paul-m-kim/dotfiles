#!/bin/bash

# environment variables
DIR_SCRIPTS="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ${DIR_SCRIPTS}/../bash/.bashrc_ext

FILE=${HOME}/.bashrc
declare -a LINES_IN_BASHRC=('. "$HOME/.asdf/asdf.sh"'
                            '. "$HOME/.asdf/completions/asdf.bash"')

# The quotes around the array is important - otherwise it will iterate for every space in the string
for LINE in "${LINES_IN_BASHRC[@]}"
do
  grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"  
done

source ${HOME}/.bashrc

sudo apt install curl

erlang_build="27.1"
elixir_build="1.17.3-otp-27"

source ${DIR_SCRIPTS}/erlang_deps.sh
asdf plugin add erlang
export KERL_BUILD_DOCS=yes && asdf install erlang ${erlang_build}
asdf global erlang ${erlang_build}

source ${DIR_SCRIPTS}/elixir_deps.sh
asdf plugin add elixir
asdf install elixir ${elixir_build}
asdf global elixir ${elixir_build}

