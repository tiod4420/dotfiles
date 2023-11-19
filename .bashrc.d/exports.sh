#!/usr/bin/env bash
#
# Global environment variables settings

# Set Homebrew bin and man to path
if [ 'osx' = "$(_os_name)" ] && _has_brew; then
	# GNU coreutils
	PATH="$(brew --prefix coreutils)/libexec/gnubin:${PATH}"
	MANPATH="$(brew --prefix coreutils)/libexec/gnuman:${MANPATH}"
	# GNU grep
	PATH="$(brew --prefix grep)/libexec/gnubin:${PATH}"
	MANPATH="$(brew --prefix grep)/libexec/gnuman:${MANPATH}"
fi

# Set language preferences
export LANG='en_US.UTF-8';
# Set locale preferences
export LC_ALL='en_US.UTF-8';

# Make vim the default editor.
export EDITOR='vim'
# Make less the default pager
export PAGER='less -R'
# Make less the default man pager
export MANPAGER='less -R';

# Increase Bash history size
export HISTSIZE='32768';
# Increase Bash history file size
export HISTFILESIZE=${HISTSIZE};
# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL='ignoreboth';

if _has_colors; then
	case $(_ls_type) in
		'gnuls')
			# Set GNU ls colors
			_dircolors="${_config_path}/dircolors"
			if [ -f ${_dircolors} ] && [ -r ${_dircolors} ]; then
				eval `dircolors -b ${_dircolors}`
			else
				eval `dircolors`
			fi
			unset _dircolors
			;;
		'bsdls')
			export CLICOLOR=1

			# Set BSD ls colors
			LSCOLORS=""
			# Directory
			LSCOLORS+="ex"
			# Symbolic link
			LSCOLORS+="gx"
			# Socket
			LSCOLORS+="fx"
			# Pipe
			LSCOLORS+="dx"
			# Executable
			LSCOLORS+="cx"
			# Block special
			LSCOLORS+="Gx"
			# Character special
			LSCOLORS+="Dx"
			# Executable with setuid bit set
			LSCOLORS+="xB"
			# Executable with setgid bit set
			LSCOLORS+="xe"
			# Directory writable to others, with sticky bit
			LSCOLORS+="xc"
			# Directory writable to others, without sticky bit
			LSCOLORS+="xd"
			export LSCOLORS
			;;
	esac

	# Set GCC messages colors
	GCC_COLORS=''
	GCC_COLORS+='error=1;31:'
	GCC_COLORS+='warning=1;35:'
	GCC_COLORS+='note=1;36:'
	GCC_COLORS+='caret=1;32:'
	GCC_COLORS+='locus=1:'
	GCC_COLORS+='quote=1'

	export GCC_COLORS

	# Set colors for man pages (no export to keep env clean)
	# Start bold mode
        _MAN_COLOR_md=$'\e[0;38;5;1m'
	# End all mode like so, us, mb, md and mr
        _MAN_COLOR_me=$'\e[0m'
	# Start standout mode
        _MAN_COLOR_so=$'\e[0;48;5;2m'
	# End standout mode
        _MAN_COLOR_se=$'\e[0m'
	# Start underline
        _MAN_COLOR_us=$'\e[0;38;5;2m'
	# End underline
        _MAN_COLOR_ue=$'\e[0m'

	# Set GTest colors
	export GTEST_COLOR=1
fi
