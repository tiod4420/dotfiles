#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Source files only in an interactive shell
[ -z "$PS1" ] && return

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
	check_file "$1" && source "$1"
}

check_file()
{
	[ -f "$1" ] && [ -r "$1" ]
}

check_has_cmd()
{
	command -v "$@" &> /dev/null
}

get_color()
{
	# Option parameters
	local OPTARG OPTIND
	local OPTERR=0
	local opts
	# Color attributes
	local is_bold=0
	local is_dim=0
	local is_underline=0
	local is_reverse=0
	local fg_color
	local bg_color
	# Output string
	local mode
	local color_str
	local e
	local msg

	# Parsing options
	while getopts "b:doim:ru" opts $@; do
		case "$opts" in
			b) bg_color=$OPTARG;;
			d) is_dim=1;;
			i) is_italic=1;;
			m) mode=$OPTARG;;
			o) is_bold=1;;
			r) is_reverse=1;;
			u) is_underline=1;;
			*) return 1;;
		esac
	done

	shift $((OPTIND -1))
	fg_color=$1
	msg=$2

	# Process color string
	if [ "reset" = "$fg_color" ]; then
		color_str=$(get_color_code reset)
	else
		local -a colors=$(
			[ 1 -eq $is_bold ] && get_color_code bold
			[ 1 -eq $is_dim ] && get_color_code dim;
			[ 1 -eq $is_reverse ] && get_color_code reverse;
			[ 1 -eq $is_underline ] && get_color_code underline;
			[ -n "$fg_color" ] && get_color_code ${fg_color} "fg"
			[ -n "$bg_color" ] && get_color_code ${bg_color} "bg"
		)

		color_str=$(join_array ";" ${colors[@]})
	fi

	# Process string
	if [ -n "$color_str" -a "gcc" != "$mode" ]; then
		color_str="\e[${color_str}m"

		case "$mode" in
			less) e=e;;
			ps1) color_str="\[${color_str}\]";;
		esac
	fi

	# Print even if empty to have status code
	echo -n${e-} "${color_str-}${msg-}"
}

get_color_code()
{
	local color=$1
	local mode=$2

	[ "bg" != "$mode" ] && mode=38 || mode=48

	case "$color" in
		reset) echo "0";;
		bold) echo "1";;
		dim) echo "2";;
		underline) echo "4";;
		reverse) echo "7";;
		color00 | black) echo "${mode};5;0";;
		color01 | red) echo "${mode};5;1";;
		color02 | green) echo "${mode};5;2";;
		color03 | yellow) echo "${mode};5;3";;
		color04 | blue) echo "${mode};5;4";;
		color05 | magenta) echo "${mode};5;5";;
		color06 | cyan) echo "${mode};5;6";;
		color07 | white) echo "${mode};5;7";;
		color08 | brblack) echo "${mode};5;8";;
		color09 | brred) echo "${mode};5;9";;
		color10 | brgreen) echo "${mode};5;10";;
		color11 | bryellow) echo "${mode};5;11";;
		color12 | brblue) echo "${mode};5;12";;
		color13 | brmagenta) echo "${mode};5;13";;
		color14 | brcyan) echo "${mode};5;14";;
		color15 | brwhite) echo "${mode};5;15";;
		color16 | orange) echo "${mode};5;16";;
		color17 | brown) echo "${mode};5;17";;
		color18) echo "${mode};5;18";;
		color19) echo "${mode};5;19";;
		color20) echo "${mode};5;20";;
		color21) echo "${mode};5;21";;
		*) echo "";;
	esac
}

get_ls_version()
{
	if ls --color -d . &> /dev/null; then
		echo "gnuls"
	elif ls -G -d . &> /dev/null; then
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

is_local_host()
{
	[ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]
}

is_normal_user()
{
	[ "root" != "$USER" ]
}

join_array()
{
	local delim=$1
	local first=$2

	shift 2 && printf "%s" "$first" "${@/#/${delim}}"
}

# Start ssh-agent if not started
if check_has_cmd /usr/bin/ssh-agent; then
	if [ -z "$SSH_AUTH_SOCK" ]; then
		[ -n "$SHELL" ] && exec /usr/bin/ssh-agent $SHELL
	fi
fi

# Start tmux if local shell and not inside tmux
if check_has_cmd tmux; then
	if [ -z "$TMUX" ]; then
		is_local_host && exec tmux
	fi
fi

bashrc
unset -f bashrc
unset -f check_and_source check_file check_has_cmd
unset -f get_color get_color_code
unset -f get_ls_version get_os_type
unset -f is_local_host is_normal_user
unset -f join_array
