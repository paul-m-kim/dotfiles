#!/bin/bash

LLDB_DAP_VERSION=18
LLVM_PACKAGES="clang-format\
               clang-tidy\
               clang-tools\
               clang\
               clangd\
               libc++-dev\
               libc++1\
               libc++abi-dev\
               libc++abi1\
               libclang-dev\
               libclang1\
               liblldb-dev\
               libllvm-ocaml-dev\
               libomp-dev\
               libomp5\
               lld\
               lldb\
               llvm-dev\
               llvm-runtime\
               llvm\
               python3-clang"

# Suggested packages: clang-18-doc wasi-libc icu-doc llvm-18-doc libomp-18-doc pkg-config

sudo apt update
sudo apt install -y ${LLVM_PACKAGES}

DOT_DIR_LLDB_DAP=$(dirname $(which lldb-dap-${LLDB_DAP_VERSION}))
sudo ln -s ${DOT_DIR_LLDB_DAP}/lldb-dap-${LLDB_DAP_VERSION} ${DOT_DIR_LLDB_DAP}/lldb-dap

