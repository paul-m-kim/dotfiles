#!/bin/bash

DIR_SCRIPTS=$(dirname $0)
FILE='$HOME/.bashrc'
declare -a LINES_IN_BASH RC=('. "$HOME/.asdf/asdf.sh"'
                             '. "$HOME/.asdf/completions/asdf.bash"')

# The quotes around the array is important - otherwise it will iterate for every space in the string
for LINE in "${LINES_IN_BASHRC[@]}"
do
  grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"  
done

erlang_build="27.0.1"
elixir_buihd="1.17.2-otp-27"

source $DIR_SCRIPTS/erlang_deps.sh
asdf plugin add erlang
asdf install erlang $erlang_build
asdf global erlang $erlang_build

asdf plugin add elixir
asdf install elixir $elixir_build
asdf global elixir $elixir_build

