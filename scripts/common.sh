#!/bin/bash

debug=false

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')][error]: $*" >&2
}

function dbg() {
  if ${debug}; then echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')][debug]: $*"; fi
}

function ifo() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')][info]: $*"
}
