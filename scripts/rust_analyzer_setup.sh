#!/bin/bash
# https://rust-analyzer.github.io/manual.html#rust-analyzer-language-server-binary

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps
RUST_ANALYZER_VERSION='2024-07-22'

# wget -nc -P ${DOT_DIR_DOWNLOADS} https://github.com/rust-lang/rust-analyzer/releases/download/${RUST_ANALYZER_VERSION}/rust-analyzer-x86_64-unknown-linux-musl.gz
wget -nc -P ${DOT_DIR_DOWNLOADS} https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz
gunzip -c ${DOT_DIR_DOWNLOADS}/rust-analyzer-x86_64-unknown-linux-gnu.gz > ${DOT_DIR_APPS}/rust-analyzer
chmod +x ${DOT_DIR_APPS}/rust-analyzer
ln -s ${DOT_DIR_APPS}/rust-analyzer ${DOT_DIR_BIN}/rust-analyzer

