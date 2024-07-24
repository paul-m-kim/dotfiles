!#/bin/bash

NEOVIM_DEPS="neovim \
             ripgrep \
             fd-file \ 
             python3-venv" 

sudo apt update
sudo apt install -y $NEOVIM_DEPS 

