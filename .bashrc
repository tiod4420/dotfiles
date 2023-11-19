#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Source files only in an interactive shell
[ -z "$PS1" ] && return
# Start ssh-agent if not started
# TODO: fix that maybe
[ -z "$SSH_AUTH_SOCK" -a -x /usr/bin/ssh-agent ] && [ -n "$SHELL" ] && exec /usr/bin/ssh-agent $SHELL

bashrc()
{
	# Setup CONFIG_DIR_PATH
	if [ -n "$XDG_CONFIG_HOME" ]; then
		local CONFIG_DIR_PATH="${$XDG_CONFIG_HOME}/bash"
	else
		local CONFIG_DIR_PATH="${HOME}/.config/bash"
	fi

	# Get OS type
	local OS=$(get_os_type)

	# Get number of colors of the terminal
	local TERM_COLORS=$(tput colors 2> /dev/null || echo 0)

	# Load generic configuration files
	local file
	for file in "global.sh" "exports.sh" "functions.sh" "aliases.sh" "prompt.sh"; do
		check_and_source "${CONFIG_DIR_PATH}/$file"
	done

	# Load local configuration files that are not commited
	# [!] Load after all other settings so it can override previous config
	local file
	for file in ${CONFIG_DIR_PATH}/local/*.sh; do
		check_and_source "$file"
	done
}

check_and_source()
{
	local file=$1
	[ -f "$file" -a -r "$file" ] && source $file
}

get_color()
{
	local color=$1

	# Return early if colors are barely supported
	[ "$TERM_COLORS" -lt 256 ] && return 0

	# TODO: handle options like set_color

	case "$color" in
		normal | reset) echo "\e[0m";;
		reverse) echo "\e[7m";;
		color00 | black) echo "\e[38;5;0m";;
		color01 | red) echo "\e[38;5;1m";;
		color02 | green) echo "\e[38;5;2m";;
		color03 | yellow) echo "\e[38;5;3m";;
		color04 | blue) echo "\e[38;5;4m";;
		color05 | magenta) echo "\e[38;5;5m";;
		color06 | cyan) echo "\e[38;5;6m";;
		color07 | white) echo "\e[38;5;7m";;
		color08 | brblack) echo "\e[38;5;8m";;
		color09 | brred) echo "\e[38;5;9m";;
		color10 | brgreen) echo "\e[38;5;10m";;
		color11 | bryellow) echo "\e[38;5;11m";;
		color12 | brblue) echo "\e[38;5;12m";;
		color13 | brmagenta) echo "\e[38;5;13m";;
		color14 | brcyan) echo "\e[38;5;14m";;
		color15 | brwhite) echo "\e[38;5;15m";;
		color16 ) echo "\e[38;5;16m";;
		color17 ) echo "\e[38;5;17m";;
		color18 ) echo "\e[38;5;18m";;
		color19 ) echo "\e[38;5;19m";;
		color20 ) echo "\e[38;5;20m";;
		color21 ) echo "\e[38;5;21m";;
		*) echo "";;
	esac
}

get_ls_version()
{
	if ls --color -d . &> /dev/null; then
		echo "gnuls"
	elif  ls -G -d . &> /dev/null; then
		echo "bsdls"
	else
		echo "unknown"
	fi
}

get_os_type()
{
	case "$(uname | tr "[:upper:]" "[:lower:]")os_type" in
		linux*) echo "linux" ;;
		darwin*) echo "osx" ;;
		freebsd*) echo "freebsd" ;;
		msys*) echo "windows" ;;
		*) echo "unknown" ;;
	esac
}

bashrc
unset -f bashrc check_and_source get_color get_ls_version get_os_type
