#!/bin/bash

TS_LIST="javascript c cpp dockerfile rust lua python go gomod graphql bash "
TS_LIST+="fish php kotlin html julia json css scss c_sharp todotxt typescript "
TS_LIST+="tsx scala haskell toml yaml regex comment jsdoc zig vim help json5 "
TS_LIST+="llvm make norg"

rm -rf "$HOME/.local/share/nvim/" "$HOME/.cache/nvim" "$HOME/.config/nvim/plugin"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' && \
    nvim --headless -c "TSInstallSync $TS_LIST" -c "sleep 30" -c "quitall" && \
    nvim --headless -c "sleep 30" -c "quitall"

echo ""
date
