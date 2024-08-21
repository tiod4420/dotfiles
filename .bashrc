#!/usr/bin/env bash

declare -A _bashrc_colors=(
	[reset]='0'         [bold]='1'           [black]='38;5;0'    [red]='38;5;1'
	[green]='38;5;2'    [yellow]='38;5;3'    [blue]='38;5;4'     [magenta]='38;5;5'
	[cyan]='38;5;6'     [white]='38;5;7'     [brblack]='38;5;8'  [brred]='38;5;9'
	[brgreen]='38;5;10' [bryellow]='38;5;11' [brblue]='38;5;12'  [brmagenta]='38;5;13'
	[brcyan]='38;5;14'  [brwhite]='38;5;15'  [color16]='38;5;16' [color17]='38;5;17'
	[color18]='38;5;18' [color19]='38;5;19'  [color20]='38;5;20' [color21]='38;5;21'
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

_bashrc_is_shell()
{
	# Check if interactive shell, should be enough according to the manual
	[ -z "$PS1" ] && return 1

	# Shell is from IntelliJ IDEA
	[ -n "$INTELLIJ_ENVIRONMENT_READER" ] && return 1
	[ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] && return 1

	# Shell is from Visual Studio Code
	[ -n "$VSCODE_PID" ] && return 1
	[ "$TERM_PROGRAM" = "vscode" ] && return 1

	true
}

_bashrc_is_ssh_agent()
{
	# Check if already running ssh-agent
	[ -n "$SSH_AUTH_SOCK" ] && return

	# Check if there is the difuse file
	[ -e ~/no-ssh-agent ] && return

	false
}

_bashrc_is_tmux()
{
	# Check if already running tmux
	[ -n "$TMUX" ] && return

	# Check if we are in an ssh session
	[ -n "$SSH_CLIENT" -o -n "$SSH_CONNECTION" -o -n "$SSH_TTY" ] && return

	# Check if there is the difuse file
	[ -e ~/no-tmux ] && return

	false
}

_bashrc_try_exec()
{
	_bashrc_has_cmd "$1" && exec "$@"
}

_bashrc_try_source()
{
	[ -f "$1" ] && source "$1"
}

_bashrc_setup_linux()
{
	local file

	# Setup bash autocomplete
	if [ -z "$BASH_COMPLETION_VERSINFO" ]; then
		_bashrc_try_source /usr/share/bash-completion/bash_completion
	fi

	# Try to source git-prompt.sh
	declare -a git_prompt=(
		# Arch Linux
		/usr/share/git/completion/git-prompt.sh
		# CentOS
		/usr/share/git-core/contrib/completion/git-prompt.sh
		# Debian
		/usr/lib/git-core/git-sh-prompt
	)

	for file in "${git_prompt[@]}"; do
		_bashrc_try_source $file && break
	done
}

_bashrc_setup_macos()
{
	local prefix=/opt/local
	local dir

	# Force fresh PATH
	[ -x /usr/libexec/path_helper ] && eval $(unset PATH && /usr/libexec/path_helper -s)

	# Set MacPorts installation path
	! _bashrc_has_cmd $prefix/bin/port && return

	# Setup bash autocomplete
	if [ -z "$BASH_COMPLETION_VERSINFO" ]; then
		_bashrc_try_source $prefix/etc/profile.d/bash_completion.sh
	fi

	# Try to source git-prompt.sh
	_bashrc_try_source $prefix/share/git/contrib/completion/git-prompt.sh

	# Setup MacPorts PATH and MANPATH
	# Reverse order as we push at front
	PATH=$(_bashrc_add_path $PATH $prefix/libexec/gnubin)
	PATH=$(_bashrc_add_path $PATH $prefix/sbin)
	PATH=$(_bashrc_add_path $PATH $prefix/bin)
	export PATH

	MANPATH=$(_bashrc_add_path $MANPATH $prefix/share/man)
	export MANPATH
}

# Don't run if we are from within an IDE
! _bashrc_is_shell && return

# Setup default PATH
case "$OSTYPE" in
	linux*) _bashrc_setup_linux;;
	darwin*) _bashrc_setup_macos;;
	*) echo "Are we GNU Hurd yet?";;
esac

! _bashrc_has_cmd cargo && _bashrc_try_source ~/.cargo/env

# Start ssh-agent, it should terminates when bash exit
! _bashrc_is_ssh_agent && _bashrc_try_exec ssh-agent ${SHELL:-bash}

# Start tmux, without attaching to a session in case we need a fresh shell
! _bashrc_is_tmux && _bashrc_try_exec tmux

# Load configuration files
_bashrc_config_dir=${XDG_CONFIG_HOME:-~/.config}/bash

_bashrc_try_source $_bashrc_config_dir/aliases.sh
_bashrc_try_source $_bashrc_config_dir/env.sh
_bashrc_try_source $_bashrc_config_dir/prompt.sh

# Local configuration (globbing should sort alphabetically)
for file in $_bashrc_config_dir/local/*.sh; do
	_bashrc_try_source $file
done

unset -v _bashrc_colors
unset -v _bashrc_config_dir
unset -v file

unset -f _bashrc_add_path
unset -f _bashrc_has_cmd
unset -f _bashrc_has_colors
unset -f _bashrc_is_shell
unset -f _bashrc_is_ssh_agent
unset -f _bashrc_is_tmux
unset -f _bashrc_try_exec
unset -f _bashrc_try_source
unset -f _bashrc_setup_linux
unset -f _bashrc_setup_macos
