#!/bin/bash

OS=$(uname -s)
ARCH=$(uname -m)
if [ "$OS" = "Darwin" ]; then
    brew upgrade &&
        brew cleanup -s --prune 0 &&
        (cd ~/.dotfiles && git up) &&
        (cd ~/.omz_custom && git up) &&
        rustup update &&
        ([ -e "$HOME/.cargo/bin/cargo-install-update" ] &&
            cargo install-update --all)
elif [ "$OS" = "Linux" ]; then
    if [ -e "/etc/debian_version" ]; then
        sudo apt -y upgrade && sudo apt -y upgrade
    fi

    if [ -x "$HOME/.appimage/appimageupdatetool-$ARCH.AppImage" ]; then
        for i in "$HOME/.appimage/"*.[Aa]pp[Ii]mage; do
            "$HOME/.appimage/appimageupdatetool-$ARCH.AppImage" "$i"
        done
    fi
else
    echo "ERROR unsupport $OS"
fi

if [ -n "$ZSH" ] && [ -d "$ZSH" ]; then
    "$ZSH/tools/upgrade.sh"
fi
