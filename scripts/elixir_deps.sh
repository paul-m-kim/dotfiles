#!/bin/bash

ELIXIR_DEPS="inotify-tools \
             postgresql \
             postgresql-contrib"

sudo apt update
sudo apt install -y ${ELIXIR_DEPS}

