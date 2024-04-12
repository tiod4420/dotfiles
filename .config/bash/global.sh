#!/usr/bin/env bash
#
# Global settings

global()
{
	case "$os_type" in
		linux) setup_linux;;
		macos) setup_macos;;
	esac

	# Add Rust development environment to PATH
	check_has_cmd cargo || add_path "${HOME}/.cargo/bin"

	# Append to the Bash history file, rather than overwriting it
	shopt -s histappend 2> /dev/null
	# Doesn't directly use history substitution
	shopt -s histverify 2> /dev/null
	# Set VI command line editing mode
	set -o vi
	# Set the binding to vi mode
	set keymap vi
}

setup_linux()
{
	# Setup bash autocomplete
	check_and_source "/usr/share/bash-completion/bash_completion"
	# Try to source git-prompt.sh if not already done
	# Arch Linux
	check_has_cmd __git_ps1 || check_and_source "/usr/share/git/completion/git-prompt.sh"
	# CentOS
	check_has_cmd __git_ps1 || check_and_source "/usr/share/git-core/contrib/completion/git-prompt.sh"
	# Debian
	check_has_cmd __git_ps1 || check_and_source "/usr/lib/git-core/git-sh-prompt"
}

setup_macos()
{
	# Force fresh path
	if [ -x /usr/libexec/path_helper ]; then
		PATH=""
		eval $(/usr/libexec/path_helper -s)
	fi

	if check_has_cmd brew; then
		# Setup Homebrew
		setup_brew
	elif check_has_cmd /opt/local/bin/port; then
		# Setup MacPorts
		setup_port
	fi
}

setup_brew()
{
	local brew_prefix
	local brew_path
	local brew_bin
	local brew_man
	local formula

	# Get Homebrew installation path
	brew_prefix="$(brew --brew_prefix)"

	# Setup bash autocomplete
	check_and_source "${brew_prefix}/opt/bash-completion/etc/profile.d/bash_completion.sh"
	check_has_cmd __git_ps1 || check_and_source "${brew_prefix}/etc/bash_completion.d/git-prompt.sh"

	# Set Homebrew formulas to PATH and MANPATH
	for formula in "coreutils" "findutils" "gnu-sed" "grep" "openssl"; do
		brew_path="${brew_prefix}/opt/${formula}"

		# Skip if path doesn't exist
		[ ! -d "$brew_path" ] && continue

		brew_bin="${brew_path}/libexec/gnubin"
		[ ! -d "$brew_bin" ] && brew_bin="${brew_path}/bin"

		brew_man="${brew_path}/libexec/gnuman"
		[ ! -d "$brew_man" ] && brew_man="${brew_path}/man"

		# Add only if not already in PATH or MANPATH
		add_path -f "$brew_bin"
		add_man -f "$brew_man"
	done
}

setup_port()
{
	local port_prefix

	# Set MacPorts installation path
	port_prefix="/opt/local"

	# Setup bash autocomplete
	check_and_source "${port_prefix}/etc/profile.d/bash_completion.sh"
	check_has_cmd __git_ps1 || check_and_source "${port_prefix}/share/git/contrib/completion/git-prompt.sh"

	# Setup MacPorts PATH
	add_path -f "${port_prefix}/bin"
	add_path -f "${port_prefix}/sbin"
	add_path -f "${port_prefix}/libexec/gnubin"
}

global
unset -f global
unset -f setup_linux setup_macos
unset -f setup_brew setup_port
