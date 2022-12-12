#!/bin/bash

currentDir="$(dirname "$0")"
source "$currentDir/config.sh"

_remove_dotfiles "$HOME/dotfiles"
_remove_packages "${__PACKAGES[@]}"
_remove_cargo_packages "${__CARGO_PACKAGES[@]}"
_remove_rust "$HOME/Repos"
_remove_directories "${__DIRS[@]}"
_clean_packages
