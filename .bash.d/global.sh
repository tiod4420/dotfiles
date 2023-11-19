#!/usr/bin/env bash
#
# Global settings

global()
{
	local BASH_CPT=""

	# Set Bash auto completion script
	if [ "osx" = "$OS" ]; then
		BASH_CPT="${BREW_PREFIX}/bash-completion/etc/profile.d/bash_completion.sh"
	elif [ "linux" = "$OS" ]; then
		BASH_CPT="/etc/bash_completion"
	fi

	[ -f "$BASH_CPT" ] && [ -r "$BASH_CPT" ] && source $BASH_CPT

	# Append to the Bash history file, rather than overwriting it
	shopt -s histappend 2> /dev/null
	# Set VI command line editing mode
	set -o vi
	# Set the binding to vi mode
	set keymap vi
}

global
unset -f global
