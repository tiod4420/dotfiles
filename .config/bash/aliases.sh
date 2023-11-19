#!/usr/bin/env bash
#
# Global alias mappings

aliases()
{
	# Easier navigation
	alias ..="cd .."
	alias ...="cd ../.."
	alias ....="cd ../../.."

	# Safe cp and mv
	alias cp="cp -i"
	alias mv="mv -i"

	# Retrieve ls version from here, as path might change during setup
	local ls_version=$(get_ls_version)
	[ "gnuls" = "$ls_version" ] && alias ls="ls --color=auto"
	[ "bsdls" = "$ls_version" ] && alias ls="ls -G"

	# ls aliases
	alias ll="ls -lh"
	alias la="ll -A"

	# Set colors for grep
	alias grep="grep --color=auto"
	# Set colors for fgrep
	alias fgrep="fgrep --color=auto"
	# Set colors for egrep
	alias egrep="egrep --color=auto"

	# Search for file or text in current directory
	alias ff="find . -name"
	alias ft="grep -RI"

	# OpenSSL fast command
	alias asn1parse="openssl asn1parse -i -dump"
	alias b64enc="openssl base64"
	alias b64dec="openssl base64 -d"
	alias rand="openssl rand"
	alias x509="openssl x509 -noout -text"

	# Convert hex to binary and reverse
	alias tobin="xxd -p -r"
	alias tohex="xxd -p -c 32"

	# Allow display of raw characters (only ANSI colors) with less
	alias less="less -F -R -X"

	# Print each MANPATH entry on a separate line
	alias manpath='man --path | tr ":" "\n"'
	# Map command to one argument
	alias map='xargs -n1'
	# Print each PATH entry on a separate line
	alias path='echo $PATH | tr ":" "\n"'
	# Check what there is to do in current directory
	alias todo="grep -RI TODO --exclude-dir={.git,build,externals}"
	# Edit todo file
	alias todolist="vim \$TODO_FILE"
	# which seems deprecated in some OS
	alias which="command -v"

	# Use Git’s colored diff when available
	check_has_cmd git && alias gdiff="git diff --no-index"

	# Normalize open across Linux and OSX
	[ "linux" = "$OS" ] && alias open="xdg-open";
}

aliases
unset -f aliases
