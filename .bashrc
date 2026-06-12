#!/usr/bin/env bash
#
# Bash configuration

# Bash config base directory
_BASHRC_CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/bash

# TTY color codes
declare -A _BASHRC_COLORS=(
	[reset]='0'         [bold]='1'           [black]='38;5;0'    [red]='38;5;1'
	[green]='38;5;2'    [yellow]='38;5;3'    [blue]='38;5;4'     [magenta]='38;5;5'
	[cyan]='38;5;6'     [white]='38;5;7'     [brblack]='38;5;8'  [brred]='38;5;9'
	[brgreen]='38;5;10' [bryellow]='38;5;11' [brblue]='38;5;12'  [brmagenta]='38;5;13'
	[brcyan]='38;5;14'  [brwhite]='38;5;15'  [color16]='38;5;16' [color17]='38;5;17'
	[color18]='38;5;18' [color19]='38;5;19'  [color20]='38;5;20' [color21]='38;5;21'
)

# Bash completion paths
declare -a _BASHRC_BASH_COMPLETION=(
	# Arch Linux
	/usr/share/bash-completion/bash_completion
	# Homebrew
	/opt/homebrew/etc/profile.d/bash_completion.sh
	# MacPorts
	/opt/local/etc/profile.d/bash_completion.sh
)

# Git prompt paths
declare -a _BASHRC_GIT_PROMPT=(
	# Arch Linux
	/usr/share/git/completion/git-prompt.sh
	# CentOS
	/usr/share/git-core/contrib/completion/git-prompt.sh
	# Debian
	/usr/lib/git-core/git-sh-prompt
	# Homebrew
	/opt/homebrew/etc/bash_completion.d/git-prompt.sh
	# MacPorts
	/opt/local/share/git/contrib/completion/git-prompt.sh
)

_bashrc_add_path()
{
	local mode=back
	local path
	local dir

	# Push front or back of PATH
	case "$1" in
		-f) mode=front && shift ;;
		-b) mode=back && shift ;;
	esac

	# Get path
	path=$1
	shift

	# Add each of the directories
	for dir in "$@"; do
		! [ -d "$dir" ] && continue

		case ":$path:" in
			*":$dir:"*) ;;
			*) path=${path:+:$path}$dir ;;
			*) path=${path:+$path:}$dir ;;
		esac
	done

	echo "$path"
}

_bashrc_has_cmd()
{
	command -v "$1" &> /dev/null
}

_bashrc_has_colors()
{
	[ "$(tput colors 2> /dev/null || echo 0)" -ge 256 ]
}

_bashrc_is_ide()
{
	# Terminal is IntelliJ IDEA
	[ -n "$INTELLIJ_ENVIRONMENT_READER" ] && return 0
	[ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] && return 0

	# Terminal is Visual Studio Code
	[ -n "$VSCODE_PID" ] && return 0
	[ "$TERM_PROGRAM" = "vscode" ] && return 0

	false
}

_bashrc_run_bashrc()
{
	# Check if there is the difuse file
	[ -e "$HOME/nobashrc" ] && return 1

	# Check if interactive shell, should be enough according to the manual
	[ -z "$PS1" ] && return 1

	true
}

_bashrc_run_ssh_agent()
{
	# Check if there is the difuse file
	[ -e "$HOME/nossh" ] && return 1

	# Check if already running ssh-agent
	[ -n "$SSH_AUTH_SOCK" ] && return 1

	# Check if we can create agent socket
	! [ -d "$HOME/.ssh/agent" -a -x "$HOME/.ssh/agent" ] && return 1

	true
}

_bashrc_run_tmux()
{
	# Check if there is the difuse file
	[ -e "$HOME/notmux" ] && return 1

	# Check if already running tmux
	[ -n "$TMUX" ] && return 1

	# Check if we are in an ssh session
	[ -n "$SSH_CLIENT" -o -n "$SSH_CONNECTION" -o -n "$SSH_TTY" ] && return 1

	true
}

_bashrc_setup_path()
{
	case "$OSTYPE" in
		darwin*)
			# Force fresh PATH
			[ -x /usr/libexec/path_helper ] && eval $(unset PATH && /usr/libexec/path_helper -s)

			if _bashrc_has_cmd /opt/homebrew/bin/brew; then
				# Setup Homebrew environment
				eval "$(/opt/homebrew/bin/brew shellenv bash)"

				# Setup PATH
				PATH=$(_bashrc_add_path -f "$PATH" \
					"${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/make/libexec/gnubin" \
					"${HOMEBREW_PREFIX}/opt/man-db/libexec/bin" \
					"${HOMEBREW_PREFIX}/opt/python/libexec/bin" \
				)
				export PATH
			elif _bashrc_has_cmd /opt/local/bin/port; then
				# Setup PATH
				PATH=$(_bashrc_add_path -f "$PATH" \
					"/opt/local/bin" \
					"/opt/local/sbin" \
					"/opt/local/libexec/gnubin" \
				)
				export PATH

				# Setup MANPATH
				MANPATH=$(_bashrc_add_path -f "$MANPATH" "/opt/local/share/man")
				export MANPATH
			fi
			;;
		linux*)
			# Nothing to do
			;;
		*)
			echo "Are we GNU Hurd yet?"
			;;
	esac

	! _bashrc_has_cmd cargo && _bashrc_try_source "$HOME/.cargo/env"
}

_bashrc_try_exec()
{
	_bashrc_has_cmd "$1" && exec "$@"
}

_bashrc_try_source()
{
	[ -f "$1" ] && source "$1"
}

# Set PATH first to have minimal setup even if _bashrc_run_bashrc is false
_bashrc_setup_path

# Check if bashrc should be sourced
! _bashrc_run_bashrc && return
# Check if we are running from an IDE
_bashrc_is_ide && return

# Start ssh-agent, it should terminates when bash exit
_bashrc_run_ssh_agent && _bashrc_try_exec ssh-agent "${SHELL:-bash}"
# Start tmux, without attaching to a session in case we need a fresh shell
_bashrc_run_tmux && _bashrc_try_exec tmux

# Source configuration files
_bashrc_try_source "$_BASHRC_CONFIG_DIR/global.sh"
_bashrc_try_source "$_BASHRC_CONFIG_DIR/aliases.sh"
_bashrc_try_source "$_BASHRC_CONFIG_DIR/prompt.sh"

# Source local configuration file
_bashrc_try_source "$_BASHRC_CONFIG_DIR/local.sh"

unset -v _BASHRC_CONFIG_DIR
unset -v _BASHRC_COLORS
unset -v _BASHRC_BASH_COMPLETION
unset -v _BASHRC_GIT_PROMPT
unset -v file

unset -f _bashrc_add_path
unset -f _bashrc_has_cmd
unset -f _bashrc_has_colors
unset -f _bashrc_is_ide
unset -f _bashrc_run_bashrc
unset -f _bashrc_run_ssh_agent
unset -f _bashrc_run_tmux
unset -f _bashrc_setup_path
unset -f _bashrc_try_exec
unset -f _bashrc_try_source
