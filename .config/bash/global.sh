#!/usr/bin/env bash
#
# Global settings

global()
{
	# Set Homebrew formulas to PATH and MANPATH
	[ "osx" = "$OS" ] && setup_osx
	# Set Bash auto completion script
	[ "linux" = "$OS" ] && setup_linux

	# Add Rust development environment to PATH
	add_path "${HOME}/.cargo/bin"

	# Append to the Bash history file, rather than overwriting it
	shopt -s histappend 2> /dev/null
	# Set VI command line editing mode
	set -o vi
	# Set the binding to vi mode
	set keymap vi
}

add_man()
{
	case :${MANPATH}: in
		*:${1}:*) return;;
		*) [ "after" = "$2" ] && MANPATH="${MANPATH}:${1}" || MANPATH="${1}:${MANPATH}";;
	esac
}

add_path()
{
	case :${PATH}: in
		*:${1}:*) return;;
		*) [ "after" = "$2" ] && PATH="${PATH}:${1}" || PATH="${1}:${PATH}";;
	esac
}

setup_linux()
{
	# Setup bash autocomplete
	check_and_source "/usr/share/bash-completion/bash_completion"
}

setup_osx()
{
	local brew_prefix
	local brew_path
	local brew_bin
	local brew_man

	# Get Homebrew's installation path, or empty string if not existing
	command -v brew &> /dev/null && brew_prefix="$(brew --prefix)/opt"

	# Setup bash autocomplete
	check_and_source "${brew_prefix}/bash-completion/etc/profile.d/bash_completion.sh"

	local formula
	for formula in "bison" "coreutils" "findutils" "gnu-sed" "grep" "openssl"; do
		brew_path="${brew_prefix}/${formula}"

		# Skip if path doesn't exist
		[ ! -d "$brew_path" ] && continue

		brew_bin="${brew_path}/libexec/gnubin"
		[ ! -d "$brew_bin" ] && brew_bin="${brew_path}/bin"

		brew_man="${brew_path}/libexec/gnuman"
		[ ! -d "$brew_man" ] && brew_man="${brew_path}/man"

		## Add only if not already in PATH or MANPATH
		add_path "$brew_bin"
		add_man "$brew_man"
	done
}

global
unset -f global add_man add_path setup_linux setup_osx
