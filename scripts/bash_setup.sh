#!/bin/bash
LINE=". $HOME/.bashrc_ext"
FILE="$HOME/.bashrc"
grep -qxF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"  
unset -v LINE FILE

