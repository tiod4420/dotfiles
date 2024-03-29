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
	case "$ls_version" in
		gnu) alias ls="ls --color=auto";;
		bsd) alias ls="ls -G";;
	esac

	# ls aliases
	alias ll="ls -lh"
	alias la="ll -A"

	# Set colors for grep
	alias grep="grep --color=auto"
	# Set colors for egrep
	alias egrep="egrep --color=auto"
	# Set colors for fgrep
	alias fgrep="fgrep --color=auto"

	# Set colors for diff
	alias diff="diff --color=auto"
	# Set colors for ip
	alias ip="ip --color=auto"

	# Search for file or text in current directory
	alias ff="find . -name"
	alias ft="grep -RI"

	# Check what there is to do in current directory
	alias todo="grep -RIi TODO --exclude-dir={.git,build,externals}"

	# Make tarball with automatic compression algorithm
	alias mktar="tar caf"
	# List content of tarball
	alias lstar="tar tvf"
	# Extract tarball
	alias untar="tar xvf"

	# OpenSSL fast command
	alias asn1parse="openssl asn1parse -i -dump"
	alias b64enc="openssl base64"
	alias b64dec="openssl base64 -d"
	alias rand="openssl rand"
	alias x509="openssl x509 -noout -text"

	# Convert hex to binary and reverse
	alias tobin="xxd -p -r"
	alias tohex="xxd -p -c 32"

	# Print each MANPATH entry on a separate line
	alias lsman="man --path | tr ':' '\n'"
	# Print each PATH entry on a separate line
	alias lspath="echo \$PATH | tr ':' '\n'"
	# Search all occurences of info in MANPATH
	alias findman="lsman | xargs -I{} find {} -name"
	# Search all occurences of command in PATH
	alias findpath="which -a"

	# Normalize open across Linux and OSX
	! check_has_cmd open && check_has_cmd xdg-open && alias open="xdg-open";
}

aliases
unset -f aliases
