#!/bin/bash

start=$(date)
rm -rf "$HOME/.local/share/nvim/" "$HOME/.cache/nvim" "$HOME/.config/nvim/plugin"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' && \
    nvim --headless -c 'LspInstallAll' -c 'quitall'

echo ""
echo "$start"
date
