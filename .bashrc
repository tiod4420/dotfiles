#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Define some utility functions

bashrc()
{
	local CONFIG_DIR_PATH="$(dirname ${BASH_SOURCE[0]})/.bashrc.d"
	declare -r -a SOURCE_FILES=(
		"${CONFIG_DIR_PATH}/global.sh"
		"${CONFIG_DIR_PATH}/exports.sh"
		"${CONFIG_DIR_PATH}/functions.sh"
		"${CONFIG_DIR_PATH}/aliases.sh"
		"${CONFIG_DIR_PATH}/prompt.sh"
	)
	local BREW_PREFIX=""
	local TERM_COLORS=0
	local LS_VERSION=""
	local OS=""
	local file=""

	# Get Homebrew's installation path, or empty string if not existing
	if command -v brew > /dev/null 2>&1; then
		BREW_PREFIX=$(brew --prefix)
	fi

	# Get number of colors of the terminal
	TERM_COLORS=$(tput colors || echo 0)

	# Get version of ls
	if ls --color -d . > /dev/null 2>&1; then
		LS_VERSION="gnuls"
	elif  ls -G -d . > /dev/null 2>&1; then
		LS_VERSION="bsdls"
	else
		LS_VERSION="unknown"
	fi

	# Check OS name
	case $(uname | tr "[:upper:]" "[:lower:]") in
		linux*)
			OS="linux"
			;;
		darwin*)
			OS="osx"
			;;
		freebsd*)
			OS="freebsd"
			;;
		msys*)
			OS="windows"
			;;
		*)
			OS="unknown"
			;;
	esac

	for file in ${SOURCE_FILES[@]}; do
		[ -f "$file" ] && [ -r "$file" ] && source $file
	done

	for file in "$config_path/extra/*.sh"; do
		[ -f "$file" ] && [ -r "$file" ] && source $file
	done
}

# Source files only in an interactive shell
[ -n "$PS1" ] && bashrc
unset -f bashrc
