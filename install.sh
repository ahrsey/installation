#!/bin/bash

currentDir="$(dirname "$0")"
source "$currentDir/config.sh"

_update_packages
_install_packages git zsh
_install_packages "${__PACKAGES[@]}"
_make_directories "${__DIRS[@]}"
_clone_repos "$HOME/.zsh" "${__ZSH_PLUGINS[0]}"
_clone_repos "$HOME/.tmux/plugins" "https://github.com/tmux-plugins/tpm"
_configure_dotfiles "$HOME/dotfiles" "https://github.com/smilingbig/.dotfiles.git"
_install_rust "$HOME/Repos"
_install_cargo_packages "${__CARGO_PACKAGES[@]}"
_install_pnpm
