#!/bin/bash

if [ "$(uname -s)" = "Darwin" ]; then
    brew upgrade &&
        brew cleanup -s --prune 0 &&
        rustup update &&
        (cd ~/.dotfiles && git up) &&
        (cd ~/.omz_custom && git up) &&
        ([ -e "$HOME/.cargo/bin/cargo-install-update" ] &&
            cargo install-update --all)
else
    echo "ERROR unsupport $(uname -s)"
fi
