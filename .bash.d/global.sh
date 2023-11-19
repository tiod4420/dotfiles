#!/usr/bin/env bash
#
# Global settings

global()
{
	local BASH_CPT=""

	# Set Bash auto completion script
	if [ "osx" = "$OS" ]; then
		BASH_CPT=${BREW_PATHS["bash-completion"]}
		BASH_CPT+="/etc/profile.d/bash_completion.sh"
	elif [ "linux" = "$OS" ]; then
		BASH_CPT="/etc/bash_completion"
	fi

	[ -f "$BASH_CPT" ] && [ -r "$BASH_CPT" ] && source $BASH_CPT

	# Setup ssh-agent
	if [ -z "$SSH_AUTH_SOCK" ]; then
		# Init SSH agent
		eval $(/usr/bin/ssh-agent 2> /dev/null)
		# Kill SSH agent
		trap "[ -n \"\$SSH_AGENT_PID\" ] && \
			eval \$(/usr/bin/ssh-agent -k &> /dev/null)" EXIT
	fi

	# Append to the Bash history file, rather than overwriting it
	shopt -s histappend 2> /dev/null
	# Set VI command line editing mode
	set -o vi
	# Set the binding to vi mode
	set keymap vi
}

global
unset -f global
