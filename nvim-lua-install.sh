#!/bin/bash

rm -rf .local/share/nvim/ .cache/nvim .config/nvim/plugin

nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' && \
    nvim --headless -c "TSInstallSync maintained" -c "quitall" && \
    nvim --headless  -c "sleep 60" -c "quitall"
