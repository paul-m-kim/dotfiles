#!/bin/bash

DOT_DIR_DOWNLOADS=$HOME/downloads
DOT_DIR_BIN=$HOME/bin
DOT_DIR_APPS=$HOME/apps
GOLANG_VERSION=1.22.5

# declare -a GOLANG_PACKAGES=('gopls'
#                             'dlv'
#                             'golangci-lint-langserver'
#                             'goimports')

declare -A GOLANG_PACKAGES                           
GOLANG_PACKAGES['gopls']='gopls'
GOLANG_PACKAGES['dlv']='dlv'
GOLANG_PACKAGES['golangci-lint-langserver']='golangci-lint'
GOLANG_PACKAGES['goimports']='goimports'

wget -nc -P ${DOT_DIR_DOWNLOADS} https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
rm -rf ${DOT_DIR_APPS}/go
tar -C ${DOT_DIR_APPS}/ -xzf ${DOT_DIR_DOWNLOADS}/go${GOLANG_VERSION}.linux-amd64.tar.gz
ln -s ${DOT_DIR_APPS}/go/bin/go ${DOT_DIR_BIN}/go
ln -s ${DOT_DIR_APPS}/go/bin/gofmt ${DOT_DIR_BIN}/gofmt

# https://go.dev/wiki/GOPATH
export GOPATH=${DOT_DIR_APPS}/go
# LSP
go install golang.org/x/tools/gopls@latest                         

# Debugger
go install github.com/go-delve/delve/cmd/dlv@latest                

# Formatter
go install golang.org/x/tools/cmd/goimports@latest                 

# Linter
go install github.com/nametake/golangci-lint-langserver@latest     

# for PACKAGE in "${GOLANG_PACKAGES[@]}"
# do
#   ln -s $GOPATH/bin/${PACKAGE} ${DOT_DIR_BIN}/${PACKAGE}
# done

for PACKAGE in "${!GOLANG_PACKAGES[@]}"
do
  ln -s $GOPATH/bin/${PACKAGE} ${DOT_DIR_BIN}/${GOLANG_PACKAGES[${PACKAGE}]}
done
