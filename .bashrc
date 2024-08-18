#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Source files only in an interactive shell
[ -z "$PS1" ] && return

bashrc()
{
	local config_dir_path
	local os_type
	local file
	local ls_version
	local term_colors

	# Get config directory
	config_dir_path=${XDG_CONFIG_HOME:-"${HOME}/.config"}/bash

	# Get OS type
	case "$(uname | tr "[:upper:]" "[:lower:]")" in
		linux*) os_type=linux;;
		darwin*) os_type=macos;;
		*bsd*) os_type=bsd;;
		msys*) os_type=windows;;
		*) os_type=unknown;;
	esac

	# Get ls type
	if ls --color -d . &> /dev/null; then
		ls_version=gnu
	elif ls -G -d . &> /dev/null; then
		ls_version=bsd
	fi

	# Get number of colors of the terminal
	term_colors=$(tput colors 2> /dev/null || echo 0)

	# Start ssh-agent if conditions are met
	if run_ssh_agent; then
		check_and_exec /usr/bin/ssh-agent $SHELL
	fi

	# Start tmux if conditions are met
	if run_tmux; then
		check_and_exec -h /opt/local/bin/ tmux
	fi

	# Load generic configuration files
	check_and_source "${config_dir_path}/global.sh"
	check_and_source "${config_dir_path}/aliases.sh"
	check_and_source "${config_dir_path}/prompt.sh"

	# Load local configuration files that are not commited
	# [!] Load after all other settings so it can override previous config
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

	if check_has_cmd "$cmd"; then
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

check_has_cmd()
{
	command -v "$@" &> /dev/null
}

check_has_file()
{
	[ -f "$1" ] && [ -r "$1" ]
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
	if ! is_local_host; then
		return 1
	fi

	# Check if OS is Linux or BSD, and if we are in graphical session
	if [ "macos" != "$os_type" ] && [ -z "$DISPLAY" ]; then
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

bashrc
unset -f bashrc
unset -f add_man add_path
unset -f check_and_exec check_and_source
unset -f check_has_cmd check_has_file
unset -f get_color get_color_code
unset -f is_ide_term is_local_host is_normal_user
unset -f join_array
unset -f run_tmux run_ssh_agent
