#!/bin/bash

set -e

OS=$(uname -s)
ARCH=$(uname -m)
if [ "$OS" = "Darwin" ]; then
    brew upgrade
    brew cleanup -s --prune 0

    (cd ~/.dotfiles && git up)
    (cd ~/.omz_custom && git up)

    if [ -x "$HOME/.cargo/bin/rustup" ]; then
        rustup update "$(rustup toolchain list | awk '/default/ {print $1}')"
    fi

    if [ -e "$HOME/.cargo/bin/cargo-install-update" ]; then
        cargo install-update --all
    fi
elif [ "$OS" = "Linux" ]; then
    if [ -e "/etc/debian_version" ]; then
        sudo apt -y upgrade && sudo apt -y upgrade
    fi

    (cd ~/.dotfiles && git up)
    (cd ~/.omz_custom && git up)

    if [ -x "$HOME/.appimage/appimageupdatetool-$ARCH.AppImage" ]; then
        for i in "$HOME/.appimage/"*.[Aa]pp[Ii]mage; do
            "$HOME/.appimage/appimageupdatetool-$ARCH.AppImage" "$i"
        done
    fi
else
    echo "ERROR unsupport $OS"
    exit 1
fi

if [ -n "$ZSH" ] && [ -d "$ZSH" ]; then
    "$ZSH/tools/upgrade.sh"
fi
