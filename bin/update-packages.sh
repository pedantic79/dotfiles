#!/bin/bash

if [ "$(uname -s)" = "Darwin" ]; then
    brew upgrade && brew cleanup -s --prune 0 && rustup update
else
    echo "ERROR unsupport $(uname -s)"
fi
