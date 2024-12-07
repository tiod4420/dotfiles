#!/usr/bin/env bash
#
# Bash configuration

# Bash config base directory
_bashrc_config_dir=${XDG_CONFIG_HOME:-~/.config}/bash

# TTY color codes
declare -A _bashrc_colors=(
	[reset]='0'         [bold]='1'           [black]='38;5;0'    [red]='38;5;1'
	[green]='38;5;2'    [yellow]='38;5;3'    [blue]='38;5;4'     [magenta]='38;5;5'
	[cyan]='38;5;6'     [white]='38;5;7'     [brblack]='38;5;8'  [brred]='38;5;9'
	[brgreen]='38;5;10' [bryellow]='38;5;11' [brblue]='38;5;12'  [brmagenta]='38;5;13'
	[brcyan]='38;5;14'  [brwhite]='38;5;15'  [color16]='38;5;16' [color17]='38;5;17'
	[color18]='38;5;18' [color19]='38;5;19'  [color20]='38;5;20' [color21]='38;5;21'
)

# Bash completion paths
declare -a _bashrc_bash_completion=(
	# Arch Linux
	/usr/share/bash-completion/bash_completion
	# MacOS
	/opt/local/etc/profile.d/bash_completion.sh
)

# Git prompt paths
declare -a _bashrc_git_prompt=(
	# Arch Linux
	/usr/share/git/completion/git-prompt.sh
	# CentOS
	/usr/share/git-core/contrib/completion/git-prompt.sh
	# Debian
	/usr/lib/git-core/git-sh-prompt
	# MacOS
	/opt/local/share/git/contrib/completion/git-prompt.sh
)

_bashrc_add_path()
{
	local path="$1"
	local dir="$2"

	if [ -d "$dir" ]; then
		case ":$path:" in
			*:"$dir":*) ;;
			*) path=$dir${path:+:$path} ;;
		esac
	fi

	echo $path
}

_bashrc_has_cmd()
{
	command -v "$1" &> /dev/null
}

_bashrc_has_colors()
{
	[ "$(tput colors 2> /dev/null || echo 0)" -ge 256 ]
}

_bashrc_run_bashrc()
{
	# Check if interactive shell, should be enough according to the manual
	[ -z "$PS1" ] && return 1

	# Shell is from IntelliJ IDEA
	[ -n "$INTELLIJ_ENVIRONMENT_READER" ] && return 1
	[ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] && return 1

	# Shell is from Visual Studio Code
	[ -n "$VSCODE_PID" ] && return 1
	[ "$TERM_PROGRAM" = "vscode" ] && return 1

	# Check if there is the difuse file
	[ -e ~/nobashrc ] && return 1

	true
}

_bashrc_run_ssh_agent()
{
	# Check if already running ssh-agent
	[ -n "$SSH_AUTH_SOCK" ] && return 1

	# Check if there is the difuse file
	[ -e ~/nossh ] && return 1

	true
}

_bashrc_run_tmux()
{
	# Check if already running tmux
	[ -n "$TMUX" ] && return 1

	# Check if we are in an ssh session
	[ -n "$SSH_CLIENT" -o -n "$SSH_CONNECTION" -o -n "$SSH_TTY" ] && return 1

	# Check if there is the difuse file
	[ -e ~/notmux ] && return 1

	true
}

_bashrc_try_exec()
{
	_bashrc_has_cmd "$1" && exec "$@"
}

_bashrc_try_source()
{
	[ -f "$1" ] && source "$1"
}

# Don't source bashrc if not required
! _bashrc_run_bashrc && return

# Setup PATH to have programs available early
case "$OSTYPE" in
	darwin*)
		# Force fresh PATH
		[ -x /usr/libexec/path_helper ] && eval $(unset PATH && /usr/libexec/path_helper -s)

		# Set MacPorts installation path
		! _bashrc_has_cmd /opt/local/bin/port && return

		# Setup MacPorts PATH (reverse order as we are pushing front)
		PATH=$(_bashrc_add_path $PATH /opt/local/libexec/gnubin)
		PATH=$(_bashrc_add_path $PATH /opt/local/sbin)
		PATH=$(_bashrc_add_path $PATH /opt/local/bin)
		export PATH

		# Setup MacPorts MANPATH
		MANPATH=$(_bashrc_add_path $MANPATH /opt/local/share/man)
		export MANPATH
		;;
	linux*)
		# Nothing to do
		;;
	*)
		echo "Are we GNU Hurd yet?"
		;;
esac

! _bashrc_has_cmd cargo && _bashrc_try_source ~/.cargo/env

# Start ssh-agent, it should terminates when bash exit
_bashrc_run_ssh_agent && _bashrc_try_exec ssh-agent ${SHELL:-bash}

# Start tmux, without attaching to a session in case we need a fresh shell
_bashrc_run_tmux && _bashrc_try_exec tmux

# Source configuration files
_bashrc_try_source $_bashrc_config_dir/global.sh
_bashrc_try_source $_bashrc_config_dir/aliases.sh
_bashrc_try_source $_bashrc_config_dir/prompt.sh

# Source local configuration files (globbing should sort alphabetically)
for file in $_bashrc_config_dir/local/*.sh; do
	_bashrc_try_source $file
done

unset -v _bashrc_config_dir
unset -v _bashrc_colors
unset -v _bashrc_bash_completion
unset -v _bashrc_git_prompt
unset -v file

unset -f _bashrc_add_path
unset -f _bashrc_has_cmd
unset -f _bashrc_has_colors
unset -f _bashrc_run_bashrc
unset -f _bashrc_run_ssh_agent
unset -f _bashrc_run_tmux
unset -f _bashrc_try_exec
unset -f _bashrc_try_source
