#!/bin/bash

ERLANG_BUILD_DEPS="build-essential \
                   autoconf \
                   m4 \
                   libncurses-dev \
                   libwxgtk3.2-dev \
                   libwxgtk-webview3.2-dev \
                   libgl1-mesa-dev \
                   libglu1-mesa-dev \
                   libpng-dev \
                   libssh-dev \
                   unixodbc-dev \
                   xsltproc \
                   fop \
                   libxml2-utils \
                   openjdk-17-jdk"

sudo apt update
sudo apt install -y $ERLANG_BUILD_DEPS

