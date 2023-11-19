#!/usr/bin/env bash
#
# Global alias mappings

aliases()
{
	local COLOR_FLAG=""

	# Easier navigation
	alias ..="cd .."
	alias ...="cd ../.."
	alias ....="cd ../../.."

	# Safe cp and mv
	alias cp="cp -i"
	alias mv="mv -i"

	# Get color flag for ls, according to the current ls version
	if [ "$TERM_COLORS" -ge 256 ]; then
		# Set colors for grep
		alias grep="grep --color=auto"
		# Set colors for fgrep
		alias fgrep="fgrep --color=auto"
		# Set colors for egrep
		alias egrep="egrep --color=auto"

		if [ "gnuls" = "$LS_VERSION" ]; then
			COLOR_FLAG="--color=auto"
		elif [ "bsdls" = "$LS_VERSION" ]; then
			COLOR_FLAG="-G"
		fi

		# Set color for ls
		alias ls="ls ${COLOR_FLAG}"

		# Redefine man to use colors with less as a pager
		#(not technically an alias)
		man()
		{
			LESS_TERMCAP_md=${MAN_COLOR_md} \
			LESS_TERMCAP_me=${MAN_COLOR_me} \
			LESS_TERMCAP_so=${MAN_COLOR_so} \
			LESS_TERMCAP_se=${MAN_COLOR_se} \
			LESS_TERMCAP_us=${MAN_COLOR_us} \
			LESS_TERMCAP_ue=${MAN_COLOR_ue} \
			command man "$@"
		}
	fi

	# Search for file or text in current directory
	alias ff="find . -name"
	alias ft="grep -R"

	# OpenSSL fast command
	alias asn1parse="openssl asn1parse -i -dump"
	alias b64enc="openssl base64"
	alias b64dec="openssl base64 -d"
	alias x509="openssl x509 -noout -text"

	# Python one-liners
	alias pol="python -c"

	# Convert hex to binary and reverse
	alias tobin="xxd -p -r"
	alias tohex="xxd -p"

	# ls aliases
	alias ll="ls -lh"
	alias la="ll -A"

	# Allow display of raw characters (only ANSI colors) with less
	alias less="less -R"

	# Print each PATH entry on a separate line
	alias path='echo -e ${PATH//:/\\n}'
	# Map command to one argument
	alias map='xargs -n1'

	# Use Git’s colored diff when available
	command -v git &> /dev/null && alias gdiff="git diff --no-index"

	# Normalize open across Linux and OSX
	[ "linux" = "$OS" ] && alias open="xdg-open";
}

aliases
unset -f aliases
