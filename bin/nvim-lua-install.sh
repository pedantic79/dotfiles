#!/bin/bash

rm -rf "$HOME/.local/share/nvim/" "$HOME/.cache/nvim" "$HOME/.config/nvim/plugin"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' && \
    nvim --headless -c "sleep 30" -c "quitall"

echo ""
date
