#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Define some utility functions

bashrc()
{
	local CONFIG_DIR_PATH="$(dirname ${BASH_SOURCE[0]})/.bash.d"
	declare -r -a SOURCE_FILES=(
		"${CONFIG_DIR_PATH}/global.sh"
		"${CONFIG_DIR_PATH}/exports.sh"
		"${CONFIG_DIR_PATH}/functions.sh"
		"${CONFIG_DIR_PATH}/aliases.sh"
		"${CONFIG_DIR_PATH}/prompt.sh"
	)
	declare -r -a BREW_FORMULAS=(
		"bash-completion"
		"bison"
		"coreutils"
		"findutils"
		"gnu-sed"
		"grep"
		"openssl@1.1"
	)
	declare -A BREW_PATHS
	local LS_VERSION=""
	local OS=""
	local PROMPT_GIT_STATUS=1
	local TERM_COLORS=0
	declare -a BREW_FORMULAS_PATH
	local BREW_FORMULA_PATH
	local file
	local i
	local UPDATABLE_CONFIG="true"

	# Get Homebrew's installation path, or empty string if not existing
	if command -v brew &> /dev/null; then
		BREW_FORMULAS_PATH=($(brew --prefix ${BREW_FORMULAS[*]}))

		for i in ${!BREW_FORMULAS[@]}; do
			BREW_FORMULA_PATH=${BREW_FORMULAS_PATH[$i]}
			BREW_PATHS[${BREW_FORMULAS[$i]}]=$BREW_FORMULA_PATH
		done
	fi

	# Get number of colors of the terminal
	TERM_COLORS=$(tput colors || echo 0)

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

	# Load generic configuration files
	for file in ${SOURCE_FILES[@]}; do
		[ -f "$file" ] && [ -r "$file" ] && source $file
	done

	# Load local configuration files that are not commited
	# [!] Load after all other settings so it can override previous config
	for file in ${CONFIG_DIR_PATH}/local/*.sh; do
		[ -f "$file" ] && [ -r "$file" ] && source $file
	done
}

# Source files only in an interactive shell
[ -n "$PS1" ] && bashrc
unset -f bashrc
