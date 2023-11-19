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
	# Set colors for fgrep
	alias fgrep="fgrep --color=auto"
	# Set colors for egrep
	alias egrep="egrep --color=auto"

	# Set colors for diff
	alias diff="diff --color=auto"
	# Set colors for ip
	alias ip="ip --color=auto"

	# Search for file or text in current directory
	alias ff="find . -name"
	alias ft="grep -RI"

	# Change permissions of file
	alias chdir="chmod u=rwx,g=rx,o=rx"
	alias chfile="chmod u=rw,g=r,o=r"
	alias chux="chmod u+x"

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
	alias pathman='man --path | tr ":" "\n"'
	# Print each PATH entry on a separate line
	alias path='echo $PATH | tr ":" "\n"'
	# Check what there is to do in current directory
	alias todo="grep -RIi TODO --exclude-dir={.git,build,externals}"

	# Start a VirtualBox VM in headless mode
	alias vmstart="VBoxManage startvm --type headless"

	# Recursively download the contents of a page
	alias webdump="wget -np -m -k -w 5 -e robots=off"
	# Download media files from a web page
	alias webmedia="wget -nd -r -l 1 -H -A png,gif,jpg,svg,jpeg,webm -e robots=off"

	# Normalize open across Linux and OSX
	! check_has_cmd open && check_has_cmd xdg-open && alias open="xdg-open";
}

aliases
unset -f aliases
