#!/usr/bin/env bash
#
# Deploy script for dotfiles

set -Eeuo pipefail

# Display error message, usage, and quit
error() {
	local msg=${1:-error}
	local ret=${2:-1}

	echo "$0: $msg" >&2

	exit $ret
}

# Deploy a file or a directory to its location
deploy() {
	local src=$1
	local depth=${2:-2}
	local file

	# Check that src is valid
	! [ -f "$src" ] && ! [ -d "$src" ] && error "'$src': No such file or directory"

	# End recursion if regular file or depth is 0
	if [ -f "$src" ] || [ "$depth" -eq 0 ]; then
		deploy_target "$src"
		return
	fi

	# Recurse into directory
	for file in "$src"/*; do
		# Check that file exists in case of empty directory
		[ -e "$file" ] && deploy "$file" "$((depth - 1))"
	done
}

# Create a symlink if destination doesn't exists
deploy_symlink() {
	local target=$1
	local link=$2

	! [ -e "$target" ] && error "'$target': No such file or directory"

	if ! [ -e "$link" ]; then
		run ln -s "$target" "$link"
		print_status "$link" "DEPLOYED"
	else
		print_status "$link" "SAME"
	fi
}

# Deploy a source file/directory to a destination
# If destination exists, confirm from user input
deploy_target() {
	local src=$1
	local dst
	local parent
	local prompt
	local choice

	# Check that src is valid
	! [ -e "$src" ] && return 1

	# Set the destination to HOME or XDG_CONFIG_HOME
	case "$src" in
		.config/*) dst=${src/#".config/"/"$XDG_CONFIG_HOME/"} ;;
		*) dst="$HOME/$src" ;;
	esac

	# Deploy file
	if ! [ -e "$dst" ]; then
		# Destination does not exist, create parent directory and copy source
		parent=$(dirname "$dst")
		! [ -e "$parent" ] && run mkdir -p "$parent"
		run cp -r "$src" "$dst"
		print_status "$dst" "DEPLOYED"
	elif git diff --no-index --quiet "$dst" "$src" &> /dev/null; then
		# Source and destination are the same
		print_status "$dst" "SAME"
	else
		# Source and destination are different
		print_status "$dst" "DIFF"

		# Make prompt
		prompt="Do you want to "
		[ -f "$src" ] && prompt+="overwrite file" || prompt+="replace directory"
		prompt+=" '"
		prompt+="$(print_color bold green)$(basename "$dst")$(print_color reset)"
		prompt+="'? [y/N/d/q] "

		# Get user choice
		while true; do
			# Quit if we failed to read
			! read -p "$prompt" choice && echo "" && return 1

			case "${choice,,}" in
				y|yes)
					# Replace destination
					run rm -rf "$dst"
					run cp -r "$src" "$dst"
					print_status "$dst" "REPLACED"
					break
					;;
				n|no)
					# Skip deployment
					print_status "$dst" "SKIP"
					break
					;;
				d|diff)
					# Display diff and retry (or true, to avoid failure)
					git diff --no-index "$dst" "$src" || true
					;;
				q*)
					# Exit the deployment
					print_status "$dst" "QUIT"
					exit 0
					;;
				*)
					# Invalid choice and retry
					echo "Choices are: yes|no|diff|quit"
					;;
			esac
		done
	fi

	return 0
}

has_cmd() {
	command -v "$1" &> /dev/null
}

# Print color code if supported
print_color() {
	local color
	local ncolors=$(tput colors 2> /dev/null)
	local -A colors=(
		[reset]=0
		[bold]=1
		[dim]=2
		[black]=30
		[red]=31
		[green]=32
		[yellow]=33
		[blue]=34
		[magenta]=35
		[cyan]=36
		[white]=37
	)

	# Color mode not supported
	! [ -z "${NO_COLOR:-}" ] && return
	! [ "${ncolors:-0}" -ge 16 ] && return

	for color in "$@"; do
		echo -ne "\e[${colors[$color]:-}m"
	done
}

# Print header for deploying of a program
print_deploy() {
	local cmd=${1:-}
	local version=$(version "$cmd")

	echo -n "$(print_color bold)Deploying "
	echo -n "$(print_color blue)$cmd$(print_color reset bold)"
	echo -n " configuration -- "
	if [ -n "$version" ]; then
		echo -n "version $(print_color blue)${version}"
	else
		echo -n "$(print_color yellow)NOT FOUND"
	fi
	echo "$(print_color reset)"
}

# Print action taken for deploying a file
print_status() {
	local path=${1/#"$HOME"/"~"}
	local status=${2:-}

	if [ -n "${DRY_RUN:-}" ]; then
		case "$status" in
			DEPLOYED|REPLACED) status="DRY RUN" ;;
		esac
	fi

	echo -n "    $path ... "

	case "${status:-}" in
		DEPLOYED) echo -n "$(print_color green)";;
		DIFF) echo -n "$(print_color bold yellow)" ;;
		DRY\ RUN) echo -n "$(print_color magenta)" ;;
		QUIT) echo -n "$(print_color red)" ;;
		REPLACED) echo -n "$(print_color cyan)" ;;
		SKIP) echo -n "$(print_color dim)" ;;
	esac

	echo -n "$status"
	echo "$(print_color reset)"
}

# Run command only if not dry-run mode
run() {
	[ -z "${DRY_RUN:-}" ] && "$@" || true
}

# Get a normalized version of a program
version() {
	local cmd=$1
	local regex='[0-9]+(\.[0-9]+)+'

	# Check if command exists
	! has_cmd "$cmd" && return 0

	# Extract version
	case "$cmd" in
		alacritty) alacritty --version | grep -Eo "$regex" ;;
		bash) echo $BASH_VERSION | grep -Eo "$regex" ;;
		cargo) cargo --version | grep -Eo "$regex" ;;
		clang-format) clang-format --version | grep -Eo "$regex" ;;
		gdb) gdb --version | grep -Eo "$regex" ;;
		git) git --version | grep -Eo "$regex" ;;
		hledger) hledger --version | grep -Eo "$regex" ;;
		ssh) ssh -V 2>&1 | grep -Eo "${regex}p[0-9]+" ;;
		tldr) tldr --version | grep -Eo "$regex" ;;
		tmux) tmux -V | grep -Eo "${regex}[a-z]" ;;
		vim) vim --version | head -n 1 | grep -Eo "$regex" ;;
	esac || true
}

# Return true if the lhs version is strictly older than the rhs
# Returns false if the lhs is the empty string
version_lt() {
	local oldest=$({ echo "$1"; echo "$2"; } | sort -V | head -n 1)
	[ -n "$1" ] && [ "$1" != "$2" ] && [ "$1" = "$oldest" ]
}

# Global variables
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# Set dry run
case "${1:-}" in
	-d|--dry-run) DRY_RUN=true && shift ;;
esac

# Check that git exists
! has_cmd git && error "git: command not found"

# Initialize and update git submodules
git submodule update --init --recursive
echo ""

# Alacritty
print_deploy alacritty
deploy .config/alacritty
echo ""

# Bash
print_deploy bash
deploy .bashrc
deploy .bash_profile
deploy .config/bash
echo ""

# Cargo
print_deploy cargo
deploy .cargo
echo ""

# clang-format
print_deploy clang-format
deploy .clang-format
echo ""

# GDB
print_deploy gdb
deploy .config/gdb
version_lt "$(version gdb)" 11.1 && deploy_symlink "$XDG_CONFIG_HOME/gdb/gdbinit" "$HOME/.gdbinit"
echo ""

# Git
print_deploy git
deploy .config/git
echo ""

# Hledger
print_deploy hledger
deploy .config/hledger
echo ""

# SSH
print_deploy ssh
! [ -d "$HOME/.ssh" ] && run mkdir --mode 700 "$HOME/.ssh"
deploy .ssh
echo ""

# Tealdeer
print_deploy tldr
deploy .config/tealdeer
echo ""

# Tmux
print_deploy tmux
deploy .config/tmux
echo ""

# Vim
print_deploy vim
deploy .config/vim
version_lt "$(version vim)" 9.2 && deploy_symlink "$XDG_CONFIG_HOME/vim" "$HOME/.vim"
echo ""

# End of deployment
echo "Deployment completed successfully!"
