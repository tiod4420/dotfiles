#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Source files only in an interactive shell
[ -z "$PS1" ] && return

bashrc()
{
	local config_dir_path
	local os_name
	local file

	# Get config directory
	config_dir_path=${XDG_CONFIG_HOME:-"${HOME}/.config"}/bash

	# Get OS type
	case "$(uname | tr "[:upper:]" "[:lower:]")" in
		linux*) os_name=linux;;
		darwin*) os_name=macos;;
		*bsd*) os_name=bsd;;
		msys*) os_name=windows;;
		*) os_name=unknown;;
	esac

	# Start ssh-agent if conditions are met
	if run_ssh_agent; then
		check_and_exec /usr/bin/ssh-agent $SHELL
	fi

	# Start tmux if conditions are met
	if run_tmux; then
		check_and_exec -h /opt/local/bin/ tmux
	fi

	if _bashrc_has_colors; then
		declare -A _bashrc_colors=(
			[reset]='0'
			[bold]='1'
			[black]='38;5;0'
			[red]='38;5;1'
			[green]='38;5;2'
			[yellow]='38;5;3'
			[blue]='38;5;4'
			[magenta]='38;5;5'
			[cyan]='38;5;6'
			[white]='38;5;7'
			[brblack]='38;5;8'
			[brred]='38;5;9'
			[brgreen]='38;5;10'
			[bryellow]='38;5;11'
			[brblue]='38;5;12'
			[brmagenta]='38;5;13'
			[brcyan]='38;5;14'
			[brwhite]='38;5;15'
			[color16]='38;5;16'
			[color17]='38;5;17'
			[color18]='38;5;18'
			[color19]='38;5;19'
			[color20]='38;5;20'
			[color21]='38;5;21'
		)
	fi

	# vi mode
	set -o vi

	# Append history to the file, to avoid multiple sessions erasing data
	shopt -s histappend 2> /dev/null
	# Don't execute directly history substitutions
	shopt -s histverify 2> /dev/null

	# TODO
	[ "$os_name" == "linux" ] && _setup_linux
	[ "$os_name" == "macos" ] && _setup_macos

	# Add Rust development environment to PATH
	! _bashrc_has_cmd cargo && add_path "${HOME}/.cargo/bin"

	# Load generic configuration files
	check_and_source "${config_dir_path}/env.sh"
	check_and_source "${config_dir_path}/prompt.sh"
	check_and_source "${config_dir_path}/aliases.sh"

	# Load local configuration files that are not commited
	# [!] Load after all other settings so it can override previous config
	# TODO: execute with order
	for file in ${config_dir_path}/local/*.sh; do
		check_and_source "$file"
	done
}

add_man()
{
	local OPTARG
	local OPTIND
	local opts
	local where="tail"
	local dir_array
	local path_array
	local dir
	local path

	# Parse arguments
	while getopts ":f" opts; do
		case "$opts" in
			f) where="head";;
			\?) echo "Invalid option: -${OPTARG}" && return 1;;
		esac
	done

	shift $((OPTIND - 1))

	# Initialize dir array
	dir_array=()
	# Split MANPATH as an array
	path_array=($(echo "${MANPATH}" | tr ':' ' '))

	# Loop over dirs
	for dir in "$@"; do
		# Check if dir exists
		! [ -d "$dir" ] && continue

		# Check that it is not in path
		for path in "${path_array[@]}"; do
			# Skip to next directory
			[ "$path" = "$dir" ] && continue 2
		done

		dir_array+=("$dir")
	done

	# Append dirs to MANPATH
	if [ ${#dir_array[@]} -gt 0 ]; then
		case "$where" in
			head) export MANPATH="$(join_array ":" ${dir_array[@]}):${MANPATH}";;
			tail) export MANPATH="${MANPATH}:$(join_array ":" ${dir_array[@]})";;
		esac
	fi
}

add_path()
{
	local OPTARG
	local OPTIND
	local opts
	local where="tail"
	local dir_array
	local path_array
	local dir
	local path

	# Parse arguments
	while getopts ":f" opts; do
		case "$opts" in
			f) where="head";;
			\?) echo "Invalid option: -${OPTARG}" && return 1;;
		esac
	done

	shift $((OPTIND - 1))

	# Initialize dir array
	dir_array=()
	# Split PATH as an array
	path_array=($(echo "${PATH}" | tr ':' ' '))

	# Loop over dirs
	for dir in "$@"; do
		# Check if dir exists
		! [ -d "$dir" ] && continue

		# Check that it is not in path
		for path in "${path_array[@]}"; do
			# Skip to next directory
			[ "$path" = "$dir" ] && continue 2
		done

		dir_array+=("$dir")
	done

	# Append dirs to PATH
	if [ ${#dir_array[@]} -gt 0 ]; then
		case "$where" in
			head) export PATH="$(join_array ":" ${dir_array[@]}):${PATH}";;
			tail) export PATH="${PATH}:$(join_array ":" ${dir_array[@]})";;
		esac
	fi
}

check_and_exec()
{
	local OPTARG
	local OPTIND
	local opts
	local hints
	local cmd

	# Parse arguments
	while getopts ":h:" opts; do
		case "$opts" in
			h) hints=$OPTARG;;
			\?) echo "Invalid option: -${OPTARG}" && exit 1;;
		esac
	done

	shift $((OPTIND - 1))

	# Get command
	cmd="$1"
	shift

	if _bashrc_has_cmd "$cmd"; then
		exec "$cmd" "$@"
	else
		# Check if command could be in hinted PATH
		cmd=$(PATH=${PATH}:${hints} command -v ${cmd} 2> /dev/null)
		[ -n "$cmd" ] && exec "$cmd" "$@"
	fi

	return 1
}

check_and_source()
{
	check_has_file "$1" && source "$1"
}

_bashrc_has_cmd()
{
	command -v "$@" &> /dev/null
}

check_has_file()
{
	[ -f "$1" ] && [ -r "$1" ]
}

is_ide_term()
{
	# Checks for IntelliJ IDEA
	[ -n "$INTELLIJ_ENVIRONMENT_READER" ] && return 0
	[ "JetBrains-JediTerm" = "$TERMINAL_EMULATOR" ] && return 0

	# Checks for Visual Studio Code
	[ -n "$VSCODE_PID" ] && return 0
	[ "vscode" = "$TERM_PROGRAM" ] && return 0

	return 1
}

join_array()
{
	local delim=$1
	local first=$2

	shift 2 && printf "%s" "$first" "${@/#/${delim}}"
}

run_tmux()
{
	# Check if already running tmux
	if [ -n "$TMUX" ]; then
		return 1
	fi

	# Check if no short circuit for tmux
	if [ -e "${HOME}/.notmux" ] || [ -e "${HOME}/notmux" ]; then
		return 1
	fi

	# Check if session is remote
	if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
		return 1
	fi

	# Check if OS is Linux or BSD, and if we are in graphical session
	if [ "macos" != "$os_name" ] && [ -z "$DISPLAY" ]; then
		return 1
	fi

	# Check that we're not running from IDE terminal
	if is_ide_term; then
		return 1
	fi

	return 0
}

run_ssh_agent()
{
	# Check if already running ssh-agent
	if [ -n "$SSH_AUTH_SOCK" ]; then
		return 1
	fi

	# Check if SHELL is set
	if [ -z "$SHELL" ]; then
		return 1
	fi

	# Check that we're not running from IDE terminal
	if is_ide_term; then
		return 1
	fi

	return 0
}

_bashrc_has_colors()
{
	local tput_colors=$(tput colors 2> /dev/null)
	[ "${tput_colors:-0}" -ge 256 ]
}

_setup_linux()
{
	# Setup bash autocomplete
	check_and_source "/usr/share/bash-completion/bash_completion"

	# Try to source git-prompt.sh
	# Arch Linux
	! _bashrc_has_cmd __git_ps1 && check_and_source "/usr/share/git/completion/git-prompt.sh"
	# CentOS
	! _bashrc_has_cmd __git_ps1 && check_and_source "/usr/share/git-core/contrib/completion/git-prompt.sh"
	# Debian
	! _bashrc_has_cmd __git_ps1 && check_and_source "/usr/lib/git-core/git-sh-prompt"
}

_setup_macos()
{
	# Force fresh path
	if [ -x /usr/libexec/path_helper ]; then
		PATH=""
		eval $(/usr/libexec/path_helper -s)
	fi

	_bashrc_has_cmd brew && _setup_homebrew
	_bashrc_has_cmd /opt/local/bin/port && _setup_macports
}

_setup_homebrew()
{
	local brew_prefix
	local brew_path
	local brew_bin
	local brew_man
	local formula

	# Get Homebrew installation path
	brew_prefix="$(brew --brew_prefix)"

	# Setup bash autocomplete
	check_and_source "${brew_prefix}/opt/bash-completion/etc/profile.d/bash_completion.sh"
	! _bashrc_has_cmd __git_ps1 && check_and_source "${brew_prefix}/etc/bash_completion.d/git-prompt.sh"

	# Set Homebrew formulas to PATH and MANPATH
	for formula in "coreutils" "findutils" "gnu-sed" "grep" "openssl"; do
		brew_path="${brew_prefix}/opt/${formula}"

		# Skip if path doesn't exist
		[ ! -d "$brew_path" ] && continue

		brew_bin="${brew_path}/libexec/gnubin"
		[ ! -d "$brew_bin" ] && brew_bin="${brew_path}/bin"

		brew_man="${brew_path}/libexec/gnuman"
		[ ! -d "$brew_man" ] && brew_man="${brew_path}/man"

		# Add only if not already in PATH or MANPATH
		add_path -f "$brew_bin"
		add_man -f "$brew_man"
	done
}

_setup_macports()
{
	local port_prefix

	# Set MacPorts installation path
	port_prefix="/opt/local"

	# Setup bash autocomplete
	check_and_source "${port_prefix}/etc/profile.d/bash_completion.sh"
	! _bashrc_has_cmd __git_ps1 && check_and_source "${port_prefix}/share/git/contrib/completion/git-prompt.sh"

	# Setup MacPorts PATH
	add_path -f "${port_prefix}/bin"
	add_path -f "${port_prefix}/sbin"
	add_path -f "${port_prefix}/libexec/gnubin"
}

bashrc
unset -f bashrc
unset -f add_man add_path
unset -f check_and_exec check_and_source
unset -f _bashrc_has_cmd check_has_file
unset -f is_ide_term
unset -f join_array
unset -f run_tmux run_ssh_agent
unset -f _bashrc_has_colors
unset -v _bashrc_colors
unset -f _setup_linux
unset -f _setup_macos
unset -f _setup_homebrew
unset -f _setup_macports
