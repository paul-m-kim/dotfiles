!#/bin/bash

sudo apt update
sudo apt install neovim ripgrep fd-file

# applications

erlang_build="27.0.1"
elixir_build="1.17.2-otp-27"
asdf plugin add erlang
asdf install erlang $erlang_build
asdf global erlang $erlang_build
asdf plugin add elixir
asdf install elixir $elixir_build
asdf global elixir $elixir_build

