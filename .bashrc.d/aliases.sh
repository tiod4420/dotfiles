#!/usr/bin/env bash
#
# Global alias mappings

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."

## Shortcuts
alias pdl="pushd ~/Downloads"
alias pws="pushd ~/Workspace"

# Get color flag for ls, according to the current ls version
_color_flag=''
if _has_colors; then
	case $(_ls_type) in
		'gnuls')
			_color_flag="--color=auto"
			;;
		'bsdls')
			_color_flag="-G"
			;;
	esac
fi

# Set color for ls
alias ls="ls ${_color_flag}"
# ls with long mode
alias ll="ls -lh"
# ll with hidden files
alias la="ll -A"
unset _color_flag

# Set colors for grep
alias grep='grep --color=auto'
# Set colors for fgrep
alias fgrep='fgrep --color=auto'
# Set colors for egrep
alias egrep='egrep --color=auto'

# Allow display of raw characters (only ANSI colors) with less
alias less='less -R'

# Redefine man to use colors with less as a pager
man()
{
	env \
		LESS_TERMCAP_mb=${_MAN_COLOR_mb} \
		LESS_TERMCAP_md=${_MAN_COLOR_md} \
		LESS_TERMCAP_me=${_MAN_COLOR_me} \
		LESS_TERMCAP_so=${_MAN_COLOR_so} \
		LESS_TERMCAP_se=${_MAN_COLOR_se} \
		LESS_TERMCAP_us=${_MAN_COLOR_us} \
		LESS_TERMCAP_ue=${_MAN_COLOR_ue} \
		man "$@"
}

## Use Git’s colored diff when available
if command -v git; then
	diff()
	{
		git diff --no-index --color-word "$@"
	}
fi

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Normalize `open` across Linux and OSX
if [ 'linux' = "$(_os_name)" ]; then
	alias open='xdg-open';
fi
