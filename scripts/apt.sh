!#/bin/bash

NEOVIM_DEPS="neovim \
             ripgrep \
             fd-file" 

sudo apt update
sudo apt install -y $NEOVIM_DEPS 

