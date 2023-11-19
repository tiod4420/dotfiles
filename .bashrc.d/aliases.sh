#!/usr/bin/env bash
#
# Global alias mappings

aliases()
{
	local COLOR_FLAG=""

	# Enable aliases to be sudo’ed
	alias sudo="sudo "

	# Easier navigation
	alias ..="cd .."
	alias ...="cd ../.."

	## Shortcuts
	alias pdl="pushd ~/Downloads"
	alias pws="pushd ~/Workspace"

	# Get color flag for ls, according to the current ls version
	if [ "$TERM_COLORS" -gt 256 ]; then
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
	fi

	# ls with long mode
	alias ll="ls -lh"
	# ll with hidden files
	alias la="ll -A"

	# Allow display of raw characters (only ANSI colors) with less
	alias less="less -R"

	## Use Git’s colored diff when available
	if command -v git > /dev/null 2>&1; then
		alias diff="git diff --no-index"
	fi

	# Reload the shell (i.e. invoke as a login shell)
	alias reload="exec ${SHELL} -l"
	# Print each PATH entry on a separate line
	alias path='echo -e ${PATH//:/\\n}'
	# Map command to one argument
	alias map='xargs -n1'

	# Normalize open across Linux and OSX
	if [ "linux" = "$OS" ]; then
		alias open="xdg-open";
	fi

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
}

aliases
unset -f aliases
