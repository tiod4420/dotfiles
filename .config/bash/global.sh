#!/usr/bin/env bash
#
# Global settings

global()
{
	# Set Homebrew formulas to PATH and MANPATH
	[ "macos" = "$OS" ] && setup_macos
	# Set Bash auto completion script
	[ "linux" = "$OS" ] && setup_linux

	# Add Rust development environment to PATH
	add_path "${HOME}/.cargo/bin"

	# Append to the Bash history file, rather than overwriting it
	shopt -s histappend 2> /dev/null
	# Doesn't directly use history substitution
	shopt -s histverify 2> /dev/null
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
	# Try to source git-prompt.sh if not already done
	# CentOS
	check_has_cmd __git_ps1 || check_and_source "/usr/share/git-core/contrib/completion/git-prompt.sh"
	# Debian
	check_has_cmd __git_ps1 || check_and_source "/usr/lib/git-core/git-sh-prompt"
	# Arch Linux
	check_has_cmd __git_ps1 || check_and_source "/usr/share/git/completion/git-prompt.sh"
}

setup_macos()
{
	local brew_prefix
	local brew_path
	local brew_bin
	local brew_man

	# Force fresh path
	if [ -x /usr/libexec/path_helper ]; then
		PATH=""
		eval $(/usr/libexec/path_helper -s)
	fi

	# Check homebrew exists
	! check_has_cmd brew && return

	# Get Homebrew's installation path, or empty string if not existing
	brew_prefix="$(brew --prefix)"

	## Setup bash autocomplete
	check_and_source "${brew_prefix}/opt/bash-completion/etc/profile.d/bash_completion.sh"
	check_has_cmd __git_ps1 || check_and_source "${brew_prefix}/etc/bash_completion.d/git-prompt.sh"

	local formula
	for formula in "coreutils" "findutils" "gnu-sed" "grep" "openssl"; do
		brew_path="${brew_prefix}/opt/${formula}"

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
unset -f global
unset -f add_man add_path
unset -f setup_linux setup_macos
