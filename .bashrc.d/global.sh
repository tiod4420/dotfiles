#!/usr/bin/env bash
#
# Global settings

# Set Bash auto completion script
if [ 'osx' = "$(_os_name)" ] && _has_brew; then
	_brew_prefix=$(brew --prefix bash-completion)
	_check_and_source "${brew_prefix}/etc/profile.d/bash_completion.sh"
	unset _brew_prefix
else
	_check_and_source "/etc/bash_completion"
fi

# Setup ssh-agent
if [ -z "${SSH_AUTH_SOCK}" ]; then
	# Init SSH agent
	eval `/usr/bin/ssh-agent`
	# Kill SSH agent
	trap '[ -n ${SSH_AGENT_PID} ] && eval `/usr/bin/ssh-agent -k`' EXIT
fi

# Append to the Bash history file, rather than overwriting it
shopt -s histappend 2> /dev/null
# e.g. **/qux` will enter ./foo/bar/baz/qux
shopt -s autocd 2> /dev/null
# Recursive globbing, e.g. `echo **/*.txt`
shopt -s globstar 2> /dev/null
# Set VI command line editing mode
set -o vi
# Set the binding to vi
set keymap vi
