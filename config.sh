#!/bin/bash

###############################################################################
# Strict Mode
###############################################################################

# Treat unset variables and parameters other than the special parameters ‘@’ or
# ‘*’ as an error when performing parameter expansion. An 'unbound variable'
# error message will be written to the standard error, and a non-interactive
# shell will exit.
#
# This requires using parameter expansion to test for unset variables.
#
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
#
# The two approaches that are probably the most appropriate are:
#
# ${parameter:-word}
#   If parameter is unset or null, the expansion of word is substituted.
#   Otherwise, the value of parameter is substituted. In other words, "word"
#   acts as a default value when the value of "$parameter" is blank. If "word"
#   is not present, then the default is blank (essentially an empty string).
#
# ${parameter:?word}
#   If parameter is null or unset, the expansion of word (or a message to that
#   effect if word is not present) is written to the standard error and the
#   shell, if it is not interactive, exits. Otherwise, the value of parameter
#   is substituted.
#
# Examples
# ========
#
# Arrays:
#
#   ${some_array[@]:-}              # blank default value
#   ${some_array[*]:-}              # blank default value
#   ${some_array[0]:-}              # blank default value
#   ${some_array[0]:-default_value} # default value: the string 'default_value'
#
# Positional variables:
#
#   ${1:-alternative} # default value: the string 'alternative'
#   ${2:-}            # blank default value
#
# With an error message:
#
#   ${1:?'error message'}  # exit with 'error message' if variable is unbound
#
# Short form: set -u
set -o nounset

# Exit immediately if a pipeline returns non-zero.
#
# NOTE: This can cause unexpected behavior. When using `read -rd ''` with a
# heredoc, the exit status is non-zero, even though there isn't an error, and
# this setting then causes the script to exit. `read -rd ''` is synonymous with
# `read -d $'\0'`, which means `read` until it finds a `NUL` byte, but it
# reaches the end of the heredoc without finding one and exits with status `1`.
#
# Two ways to `read` with heredocs and `set -e`:
#
# 1. set +e / set -e again:
#
#     set +e
#     read -rd '' variable <<HEREDOC
#     HEREDOC
#     set -e
#
# 2. Use `<<HEREDOC || true:`
#
#     read -rd '' variable <<HEREDOC || true
#     HEREDOC
#
# More information:
#
# https://www.mail-archive.com/bug-bash@gnu.org/msg12170.html
#
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

# export HOME="~"

export __PACKAGES=(
  neovim
  kitty
  ripgrep
  bat
  shellcheck
  blueutil
  docker
  htop
  jq
  fzf
	zplug
  wget
  curl
	terraform
  tmux
  stow
  gcc-multilib
  libssl-dev
  pkg-config
	tldr
  brave-browser
  google-chrome
	yarn
	dict
	mutt
	golang
	awscli
	bash
	gdb
	node
	tree
	gnu-sed
	fend
)

export __CARGO_PACKAGES=(
  git-delta
)

export __DIRS=(
  "$HOME/.zsh" # zsh plugin and config bits
  "$HOME/.tmux/plugins" # tmux plugins and config bits
  "$HOME/dotfiles" # dotfiles
  "$HOME/Repos" # Repository directory
)

export __ZSH_PLUGINS=(
  "https://github.com/sindresorhus/pure"
)

export __TMUX_PLUGINS=()

__DEBUG_COUNTER=0
_debug() {
  if ((${_USE_DEBUG:-0}))
  then
    __DEBUG_COUNTER=$((__DEBUG_COUNTER+1))
    {
			tput setaf 3
      # Prefix debug message with "bug (U+1F41B)"
      printf "💊 %s " "${__DEBUG_COUNTER}"
      "${@}"
			tput sgr0
      printf "\\n"
    } 1>&2
  fi
}

_command_exists() {
  hash "${1}" 2>/dev/null
}

_dir_present() {
  [[ -d "${1:-}" ]]
}

_present() {
  [[ -n "${1:-}" ]]
}

_exit_1() {
  {
    printf "%s " "$(tput setaf 1)!$(tput sgr0)"
    "${@}"
  } 1>&2
  exit 1
}

_is_macos() {
	[[ $(uname -s) == 'Darwin' ]]
}

_clean_packages() {
  _debug printf "Cleaning up unrequired deps"
	if _is_macos; then
		brew autoremove
		brew cleanup
	else
		sudo apt-get -y autoremove
		sudo apt-get -y clean
		sudo apt-get -y autoclean
	fi
}

_update_packages() {
	if _is_macos; then
		if ! _command_exists brew; then
			_debug printf "Brew is not installed, installing now"
			_install_brew
		fi
	fi

  _debug printf "Updating packages"

	if _is_macos; then
		brew update
		brew upgrade --force
		brew analytics off
	else
		sudo apt-get update
		sudo apt-get upgrade
	fi

  trap _clean_packages EXIT
}

_install_packages() {

  for __p in "$@"
  do
    if ! _command_exists "${__p}"; then
    _debug printf "Installing %s" "${__p}"
		if _is_macos; then
			brew install "${__p}" || true
		else
			sudo apt-get install -y "${__p}" || true
		fi
    else
      _debug printf "Package: %s already installed" "${__p}"
    fi
  done
}

# TODO
# _command_exists not tested here
_remove_packages() {
  for __r in "$@"
  do
    #if _command_exists "${__r}"; then
			_debug printf "Removing %s" "${__r}"
			if _is_macos; then
				brew uninstall "${__r}" || true
			else
				sudo apt-get remove -y "${__r}" || true
			fi
    #else
    #  _debug printf "Package: %s wasn't installed \\n" "${__r}"
    #fi
  done
}

_make_directories() {
  for __d in "$@"
  do
    if ! _dir_present "${__d}"; then
      _debug printf "Make dir: %s" "${__d}"
      mkdir -p "${__d}" || continue
    else
      _debug printf "Directory: %s already made" "${__d}"
    fi
  done
}

_remove_directories() {
  for __d in "$@"
  do
    if _dir_present "${__d}"; then
      _debug printf "Removing: %s" "${__d}"
      rm -fr "${__d}"
    else
      _debug printf "Directory: %s doesnt exist" "${__d}"
    fi
  done
}

_clone_repos() {
  local __req=(
    git
  )
  _make_directories "$1"
  _install_packages "${__req[@]}"

  for __c in "${@:2}"
  do
    local target_dir
    target_dir="${1}/$(basename "${__c}")"
    _debug printf "Cloning: %s into: %s " "${__c}" "${target_dir}"
    git clone "${__c}" "${target_dir}"
  done
}

_update_repos() {
  if ! _dir_present "${1}"; then
    _debug printf "Can't update repos because %s isn't made." "${1}"
    _exit_1 printf "Can't update repos because %s isn't made." "${1}"
  fi

  for __c in "${@:2}"
  do
    local target_dir
    target_dir="${1}/$(basename "${__c}")"

    if ! _dir_present "${target_dir}"; then
      _debug printf "Directory: %s not found" "${target_dir}"
    fi

    _debug printf "Updating: %s in: %s" "${target_dir}" "${1}"
    git --git-dir="${target_dir}"/.git --work-tree="${target_dir}" pull --autostash
  done
}

_configure_dotfiles() {
  local __req=(
    stow
    git
  )

  _debug printf "Setup dotfiles." 

  _make_directories "${1}"
  _install_packages "${__req[@]}"

  _debug printf "Cloning %s into %s" "${2}" "${1}"
  git clone "${2}" "${1}"

  _debug printf "CDing into %s" "$1"

  cd "$1"

  for __dir in * ; do
    if _dir_present "${__dir}"; then 
      _debug printf "Setting up dotfiles for: %s" "${__dir}"
      stow "${__dir}"
    fi
  done

  _debug printf "Stow completed."
}

_update_dotfiles() {
  local __req=(
    stow
    git
  )

  if ! _dir_present "$1"; then
    _debug printf "Dotfiles folder required."
    _exit_1 printf "Dotfiles folder required."
  fi

  _debug printf "Updating dotfiles" 
  _install_packages "${__req[@]}"

  _debug printf "Updating %s" "$1" 
  git --git-dir="${1}"/.git --work-tree="${1}" pull --autostash

  cd "$1"

  for __dir in * ; do
    if _dir_present "${__dir}"; then 
      _debug printf "Restowing: %s" "${__dir}"
      stow --restow "${__dir}"
    fi
  done

  _debug printf "stow updated"
}

_remove_dotfiles() {
  _debug printf "Remove dotfiles" 

  if ! _dir_present "${1}"; then 
    _debug printf "Dotfiles directory isn't setup, can't remove configs"
    return
  fi

  _debug printf "CDing into %s" "$1"
  cd "$1"

  for __dir in * ; do
    if _dir_present "${__dir}"; then 
      _debug printf "Removing dotfiles for: %s" "${__dir}"
      stow --delete "${__dir}"
    fi
  done

  _remove_directories "${1}"
  _remove_packages stow

  _debug printf "Stow completed."
}

_install_rust() {
  local __req=(
    git
    gcc-multilib
  )
  _install_packages "${__req[@]}"

  _make_directories "$1"

  _debug printf "Cloning rustup for installation"
  git clone "https://github.com/rust-lang/rustup" "$1/rustup" 

	# add this after rust installation script to install without prompts
	# sh -s -- -y

  bash "$1"/rustup/rustup-init.sh -y 

  . "$HOME/.cargo/env"

  cargo install cargo-update
}

_update_rust() {
  if ! _command_exists rustup; then
    _debug printf "Rustup is not installed"
    return
  fi
  if ! _command_exists cargo; then
    _debug printf "Cargo is not installed"
    return
  fi

  _debug printf "Updating Rust via rustup"
  rustup update
  _debug printf "Updating all packages installed via cargo"
  cargo install-update -a
}

_remove_rust() {
  _remove_directories "$1/rustup"
  if ! _command_exists rustup; then
    _debug printf "Rustup is not installed"
    return
  fi

  _debug printf "Removing Rust via rustup"
  rustup self uninstall
}

_install_cargo_packages() {
  if ! _command_exists cargo; then
    _debug printf "Cargo is not installed"
    return
  fi

  for __p in "$@"
  do
    _debug printf "Installing %s" "${__p}"
    cargo install "${__p}" || true
  done
}

_remove_cargo_packages() {
  for __p in "$@"
  do
    _debug printf "Removing %s" "${__p}"
    cargo uninstall "${__p}" || true
  done
}

_setup_zsh() {
  local __req=(
    zsh
  )

  _install_packages "${__req[@]}"

  _debug printf "Changing shell to zsh"
  chsh -s "$(which zsh)"

  . "$HOME/.zshrc"

  _debug printf "$SHELL"
}

_setup_bash() {
  _debug printf "Changing shell to bash"
  chsh -s "$(which bash)"

  . "$HOME/.bashrc"

  _debug printf "$SHELL"
}

_install_brew() {
	if _is_macos; then
		_debug printf "Installing xcode-select if required and brew"
		xcode-select --install || continue
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		brew analytics off
	else
		_debug printf "Brew not required"
	fi
}

_update_nvim_plugins() {
  if _command_exists nvim; then
		_debug printf "Updating nvim plugins and treesitter grammars"
		nvim --headless '+Lazy! sync' +qa
		nvim --headless ':TSUpdate' +qa
		nvim --headless ':MasonToolsUpdate' +qa
		printf '\n'
	else
		_debug printf "Nvim required do updates"
	fi
}

_update_tmux_plugins() {
  if _command_exists tmux; then
		bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh
	else
		_debug printf "Tmux required do updates"
	fi
}

_install_pnpm() {
	_debug printf "Installing pnpm"
	curl -fsSL https://get.pnpm.io/install.sh | sh -
	_debug printf "Successfully installed"
	_debug printf "Setting up pnpm completion"
	pnpm install-completion zsh
}

_update_pnpm() {
  if _command_exists pnpm; then
		_debug printf "Updating pnpm from $(pnpm --version)"
		pnpm add --global pnpm
		_debug printf "Update pnpm to $(pnpm --version)"
		_debug printf "Updating global pnpm packages"
		pnpm update --global
	else
		_debug printf "pnpm not installed, couldn't udpate"
	fi
}

_update_tldr_db() {
		_debug printf "Updating tldr database"
		tldr --update
		_debug printf "tldr database upated"
}

# https://pnpm.io/uninstall
# _uninstall_pnpm() {
# }

_docker_cleanup() {
	_debug printf "Cleaning up docker related jazz"
	docker system prune -a -f
	docker image prune -f
	docker volume prune -f
	_debug printf "Done cleaning docker"
}

_update_macos() {
	_debug printf "Updating macos"
	sudo softwareupdate -i -a -R
	_debug printf "Done updating macos"
}

export _USE_DEBUG=0
