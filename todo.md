# Requirements 
- Config file to specify requirements

# Methods
## Install
- Install package manager if required, update package manager
- Install required packages via package manager
- Create required directories
- Clone zsh plugins and tmux plugins and other required repos
- Clone dotfiles and stow all files in folder
- Install cargo/rustup etc pnpm and whatever

## Update
- Update all packages on current system, clean and all the things via package manager.
- Update all repos cloned via install, zsh, repo etc
- Update stow git directory and restow dependancies
- Update cargo/rustup etc and rust global dependancies
- Update any other package managed dependancies npm etc
- Update nvim plugins
- Update tmux plugins

## Uninstall
- Stow
  Unstow/delete currently stowed assetse 
  Delete dotfiles directory
  Delete stow
- Directories
  Delete directories created in other steps
  zsh plugins, tmux plugins, vim plugins, repos, dotfiles
- Remove installed packages
  remove everything installed via package manager, cargo, npm nvim plugins tmux plugins etc
- Remove cargo/rust/pnpm
