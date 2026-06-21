#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as an error, and prevent masking pipeline errors.
set -euo pipefail

# Setup colors for stdout messages if connected to a TTY
if [ -t 1 ]; then
    CYAN=$'\e[36m'
    NORMAL=$'\e[0m'
else
    CYAN=""
    NORMAL=""
fi

info() {
    echo "${CYAN}$1${NORMAL}"
}

update_rust() {
    if command -v rustup >/dev/null 2>&1; then
        info "Updating Rust toolchains..."
        rustup update
    fi

    if command -v cargo-install-update >/dev/null 2>&1; then
        info "Updating cargo packages..."
        if command -v rustup >/dev/null 2>&1 && rustup toolchain list | grep -q '^stable'; then
            cargo +stable install-update --all
        else
            cargo install-update --all
        fi
    fi
}

update_python() {
    if command -v uv >/dev/null 2>&1; then
        info "Updating python tools..."
        # On Darwin/macOS, Homebrew manages upgrading uv.
        if [ "${OS:-}" != "Darwin" ]; then
            uv self update || true
        fi
        uv tool upgrade --all || true
    fi
}

# Determine OS and Architecture
OS=$(uname -s)
ARCH=$(uname -m)

info "Running OS-specific package manager updates..."
if [ "$OS" = "Darwin" ]; then
    if command -v brew >/dev/null 2>&1; then
        brew update
        brew upgrade --yes
        brew cleanup -s --prune 0
    fi
elif [ "$OS" = "Linux" ]; then
    if [ -e "/etc/debian_version" ]; then
        sudo apt -y update && sudo apt -y upgrade
    fi

    if [ -x "$HOME/.appimage/appimageupdatetool-$ARCH.AppImage" ]; then
        for i in "$HOME/.appimage/"*.[Aa]pp[Ii]mage; do
            [ -e "$i" ] || continue
            "$HOME/.appimage/appimageupdatetool-$ARCH.AppImage" "$i"
        done
    fi
else
    echo "ERROR: Unsupported OS $OS"
    exit 1
fi

# Git repositories updates
info "Updating repositories..."
if [ -d "$HOME/.dotfiles" ]; then
    (cd "$HOME/.dotfiles" && git up)
fi
if [ -d "$HOME/.omz_custom" ]; then
    (cd "$HOME/.omz_custom" && git up)
fi

# Run language package updates
update_rust
update_python

# ZSH update checking
if [ -n "${ZSH:-}" ] && [ -d "$ZSH" ]; then
    info "Updating Oh My Zsh..."
    if [ -f "$ZSH/tools/upgrade.sh" ]; then
        "$ZSH/tools/upgrade.sh" &&
            printf 'LAST_EPOCH=%d\n' $((EPOCHSECONDS / 86400)) >|"$ZSH/cache/.zsh-update"
    fi
fi
