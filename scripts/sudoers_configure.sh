#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "[error] sudo needed"
  exit 1
fi

if [[ ! -f /etc/sudoers.d/50-editor ]]; then

  sudo tee /etc/sudoers.d/50-editor >/dev/null <<'EOF'
# This allows running arbitrary commands, but so does ALL, and it means
# different sudoers have their choice of editor respected.
Defaults:%sudo env_keep += "EDITOR"
EOF

fi
