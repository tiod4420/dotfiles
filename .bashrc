#!/usr/bin/env bash
#
# Bash configuration

# Bash config base directory
_BASHRC_CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/bash

# Set normalized OS name
case "${OSTYPE:-}" in
	linux*) _BASHRC_OSTYPE=linux ;;
	darwin*) _BASHRC_OSTYPE=macos ;;
	mingw* | msys* | cygwin*) _BASHRC_OSTYPE=windows ;;
	*bsd*) _BASHRC_OSTYPE=bsd ;;
	*) echo "Are we GNU Hurd yet?" ;;
esac

# Android SDK paths
declare -a _BASHRC_ANDROID_HOME=(
	# Linux
	$HOME/.local/android/sdk
	# macOS
	$HOME/Library/Android/sdk
)

# TTY color codes
declare -A _BASHRC_COLORS=(
	[reset]="0" [bold]="1" [dim]="2" [italic]="3"
	[black]="38;5;0" [red]="38;5;1" [green]="38;5;2" [yellow]="38;5;3"
	[blue]="38;5;4" [magenta]="38;5;5" [cyan]="38;5;6" [white]="38;5;7"
	[brblack]="38;5;8" [brred]="38;5;9" [brgreen]="38;5;10" [bryellow]="38;5;11"
	[brblue]="38;5;12" [brmagenta]="38;5;13" [brcyan]="38;5;14" [brwhite]="38;5;15"
	[color16]="38;5;16" [color17]="38;5;17" [color18]="38;5;18" [color19]="38;5;19"
	[color20]="38;5;20" [color21]="38;5;21"
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

_bashrc_add_path() {
	local mode=pathfront
	local path
	local new_path
	local dir

	# Add to PATH or MANPATH, front or back
	case "$1" in
		-p | --path) mode=pathfront && shift ;;
		-P | --PATH) mode=pathback && shift ;;
		-m | --manpath) mode=manfront && shift ;;
		-M | --MANPATH) mode=manback && shift ;;
	esac

	# Get original path
	case "$mode" in
		path*) path=$PATH ;;
		man*) path=$MANPATH ;;
	esac

	# Add directories to new path
	for dir in "$@"; do
		! [ -d "$dir" ] && continue

		case ":$path:" in
			*:"$dir":*) ;;
			*) new_path+=":$dir" ;;
		esac
	done

	# Early return if nothing to add
	[ -z "$new_path" ] && return

	# Update front or back
	case "$mode" in
		*front) path="${new_path#:}:$path" ;;
		*back) path="$path:${new_path#:}" ;;
	esac

	# Update PATH or MANPATH
	case "$mode" in
		path*) PATH=$path ;;
		man*) MANPATH=$path ;;
	esac
}

_bashrc_exec_tmux() {
	# Skip if tmux is not installed
	! _bashrc_has_cmd tmux && return

	# Skip if there is the sentinel defuse file
	[ -e "$HOME/notmux" ] && return

	# Skip if already running tmux
	[ -n "$TMUX" ] && return

	# Skip if inside an SSH session
	[ -n "$SSH_CLIENT" -o -n "$SSH_CONNECTION" -o -n "$SSH_TTY" ] && return

	# Exec tmux
	# Not attaching to existing session in case a fresh terminal is needed
	exec tmux
}

_bashrc_has_cmd() {
	command -v "$1" &> /dev/null
}

_bashrc_has_colors() {
	local colors=$(tput colors 2> /dev/null)
	[ "${colors:-0}" -ge 256 ]
}

_bashrc_is_enabled() {
	# Skip if there is the sentinel defuse file
	[ -e "$HOME/nobashrc" ] && return 1

	# Skip if not interactive shell
	# Bash sets PS1 if the shell is interactive, according to manual
	[ -z "$PS1" ] && return 1

	# Skip if running from IntelliJ IDEA
	[ -n "$INTELLIJ_ENVIRONMENT_READER" ] && return 1
	[ "$TERMINAL_EMULATOR" = "JetBrains-JediTerm" ] && return 1

	# Skip if running from Visual Studio Code
	[ -n "$VSCODE_PID" ] && return 1
	[ "$TERM_PROGRAM" = "vscode" ] && return 1

	return 0
}

_bashrc_setup_path() {
	if [ "$_BASHRC_OSTYPE" = "macos" ]; then
		# Force fresh PATH
		[ -x /usr/libexec/path_helper ] && eval $(unset PATH && /usr/libexec/path_helper -s)

		if _bashrc_has_cmd /opt/homebrew/bin/brew; then
			# Setup Homebrew environment
			eval "$(/opt/homebrew/bin/brew shellenv bash)"

			# Setup PATH
			_bashrc_add_path --path \
				"$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/grep/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/make/libexec/gnubin" \
				"$HOMEBREW_PREFIX/opt/man-db/libexec/bin" \
				"$HOMEBREW_PREFIX/opt/python/libexec/bin"
		elif _bashrc_has_cmd /opt/local/bin/port; then
			# Setup PATH and MANPATH
			_bashrc_add_path --path "/opt/local/bin" "/opt/local/sbin" "/opt/local/libexec/gnubin"
			_bashrc_add_path --manpath "/opt/local/share/man"
			# Export MANPATH in case it wasn't yet
			export MANPATH
		fi

		# Add Firefox to PATH
		_bashrc_add_path --PATH "/Applications/Firefox.app/Contents/MacOS"
	fi

	# Add Rust binaries to PATH
	_bashrc_try_source "$HOME/.cargo/env"
}

_bashrc_ssh_agent() {
	local file=${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.env

	# Skip if ssh is not installed
	! _bashrc_has_cmd ssh && return

	# Skip if there is the sentinel defuse file
	[ -e "$HOME/nossh" ] && return

	# Skip if SSH_AUTH_SOCK is already set
	[ -e "$SSH_AUTH_SOCK" ] && return

	# Skip if no SSH key is available
	! find "$HOME/.ssh" -type f -name "id_*" | grep -q . && return

	# Start the ssh-agent
	if ! pgrep -u "$USER" ssh-agent > /dev/null; then
		ssh-agent -t 1h > "$file"
	fi

	# Source the ssh-agent environment variables
	_bashrc_try_source "$file" > /dev/null
}

_bashrc_try_source() {
	[ -f "$1" ] && source "$1"
}

# Set PATH first, to have minimum valid environment
_bashrc_setup_path

if _bashrc_is_enabled; then
	# Exec tmux if needed
	_bashrc_exec_tmux

	# Start ssh-agent
	_bashrc_ssh_agent

	# Source configuration files
	_bashrc_try_source "$_BASHRC_CONFIG_DIR/global.sh"
	_bashrc_try_source "$_BASHRC_CONFIG_DIR/aliases.sh"
	_bashrc_try_source "$_BASHRC_CONFIG_DIR/functions.sh"
	_bashrc_try_source "$_BASHRC_CONFIG_DIR/prompt.sh"

	# Source local configuration file
	_bashrc_try_source "$_BASHRC_CONFIG_DIR/local.sh"
	_bashrc_try_source "$_BASHRC_CONFIG_DIR/secrets.sh"
fi

unset -v _BASHRC_ANDROID_HOME
unset -v _BASHRC_BASH_COMPLETION
unset -v _BASHRC_COLORS
unset -v _BASHRC_CONFIG_DIR
unset -v _BASHRC_GIT_PROMPT
unset -v _BASHRC_OSTYPE

unset -f _bashrc_add_path
unset -f _bashrc_exec_tmux
unset -f _bashrc_has_cmd
unset -f _bashrc_has_colors
unset -f _bashrc_is_enabled
unset -f _bashrc_setup_path
unset -f _bashrc_ssh_agent
unset -f _bashrc_try_source
