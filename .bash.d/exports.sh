#!/usr/bin/env bash
#
# Global environment variables settings

exports()
{
	local DIR_COLORS=""
	local BREW_BIN=""
	local BREW_MAN=""
	declare -r -a BREW_UTILS=(
		"bison"
		"coreutils"
		"findutils"
		"gnu-sed"
		"grep"
		"openssl@1.1"
	)
	local i

	# Add Rust development environment to PATH
	PATH="${HOME}/.cargo/bin:${PATH}"

	# Set Homebrew bin and man to PATH and MANPATH
	if [ "osx" = "$OS" ]; then
		# Loop over all brew utils that we want into our PATH
		for i in ${BREW_UTILS[@]}; do
			# Skip if empty
			[ -z "${BREW_PATHS[$i]}" ] && continue

			# Add only if not already in PATH
			BREW_BIN="${BREW_PATHS[$i]}/libexec/gnubin"
			[ ! -d "$BREW_BIN" ] && BREW_BIN="${BREW_PATHS[$i]}/bin"
			if ! echo $PATH | grep -q $BREW_BIN; then
				if [ -d "$BREW_BIN" ]; then
					PATH="${BREW_BIN}:${PATH}"
				fi
			fi

			# Add only if not already in MANPATH
			BREW_MAN="${BREW_PATHS[$i]}/libexec/gnuman"
			[ ! -d "$BREW_MAN" ] && BREW_MAN="${BREW_PATHS[$i]}/man"
			if ! echo $MANPATH | grep -q $BREW_MAN; then
				if [ -d "$BREW_MAN" ]; then
					MANPATH="${BREW_MAN}:${MANPATH}"
				fi
			fi
		done
	fi

	# Get version of ls and set in script variable
	if ls --color -d . &> /dev/null; then
		LS_VERSION="gnuls"
	elif  ls -G -d . &> /dev/null; then
		LS_VERSION="bsdls"
	else
		LS_VERSION="unknown"
	fi

	# Set language preferences
	export LANG="en_US.UTF-8";
	# Set locale preferences
	export LC_ALL="en_US.UTF-8";

	# Make vim the default editor.
	export EDITOR="vim"
	# Make less the default pager
	export PAGER="less -R"
	# Make less the default man pager
	export MANPAGER="less -R";

	# Increase Bash history size
	export HISTSIZE="32768";
	# Increase Bash history file size
	export HISTFILESIZE=$HISTSIZE;
	# Omit duplicates and commands that begin with a space from history.
	export HISTCONTROL="ignoreboth";

	if [ "$TERM_COLORS" -ge 256 ]; then
		if [ "gnuls" = "${LS_VERSION}" ]; then
			# Set GNU ls colors
			DIR_COLORS="${CONFIG_DIR_PATH}/dircolors"
			if [ -f "$DIR_COLORS" ] && [ -r "$DIR_COLORS" ]; then
				eval $(dircolors -b $DIR_COLORS)
			else
				eval $(dircolors)
			fi
		elif [ "bsdls" = "${LS_VERSION}" ]; then
			# Turn on colors
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
		fi

		# Set GCC messages colors
		GCC_COLORS=""
		GCC_COLORS+="error=1;31:"
		GCC_COLORS+="warning=1;35:"
		GCC_COLORS+="note=1;36:"
		GCC_COLORS+="caret=1;32:"
		GCC_COLORS+="locus=1:"
		GCC_COLORS+="quote=1"
		export GCC_COLORS

		# Set colors for man pages (no export to keep env clean)
		# Start bold mode
		MAN_COLOR_md=$'\e[0;38;5;3m'
		# End all mode like so, us, mb, md and mr
		MAN_COLOR_me=$'\e[0m'
		# Start standout mode
		MAN_COLOR_so=$'\e[0;48;5;2m'
		# End standout mode
		MAN_COLOR_se=$'\e[0m'
		# Start underline
		MAN_COLOR_us=$'\e[0;38;5;2m'
		# End underline
		MAN_COLOR_ue=$'\e[0m'

		# Set GTest colors
		export GTEST_COLOR=1
	fi
}

exports
unset -f exports
