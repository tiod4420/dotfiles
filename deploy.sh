#!/usr/bin/env bash
#
# Deploy script for dotfiles

set -Eeuo pipefail

# XDG config directory
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# Deploy a file or a directory to its location
deploy() {
	local src=$1
	local file
	local file2

	if [ -f "$src" ]; then
		# Deploy single file
		deploy_target "$src"
	else
		# Deploy a directory
		for file in $src/*; do
			if [ -f "$file" ]; then
				# Single files
				deploy_target "$file"
			else
				# Recurse one level in the directory
				for file2 in $file/*; do
					deploy_target "$file2"
				done
			fi
		done
	fi

	return 0
}

# Create a symlink if destination doesn't exists
deploy_symlink() {
	! [ -e "$1" ] && ln -s "$1" "$2"
}

# Deploy a source file/directory to a destination
# If destination exists, confirm from user input
deploy_target() {
	local src=$1
	local dst
	local parent
	local action
	local prompt
	local choice

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
		! [ -e "$parent" ] && mkdir -p "$parent"
		cp -r "$src" "$dst"
		print_status "$dst" "DEPLOYED"
	elif git diff --no-index --quiet "$dst" "$src" &> /dev/null; then
		# Source and destination are the same
		print_status "$dst" "SAME"
	else
		# Source and destination are different
		print_status "$dst" "DIFF"

		# Make prompt
		[ -f "$src" ] && action="overwrite file" || action="replace directory"
		prompt="Do you want to ${action} '$(basename "$dst")'? [y/N/d/q] "

		# Get user choice
		while true; do
			# Quit if we failed to read
			! read -p "$prompt" choice && echo "" && return 1

			case "${choice,,}" in
				y|yes)
					# Replace destination
					rm -rf "$dst"
					cp -r "$src" "$dst"
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

# Print header for deploying of a program
print_deploy() {
	local version=$(version_get "$1")
	echo "Deploying $1 configuration -- ${version:+version }${version:-NOT FOUND}"
}

# Print action taken for deploying a file
print_status() {
	echo "    ${1/#"$HOME"/"~"} ... ${2:-}"
}

# Get a normalized version of a program
version_get() {
	local cmd=$1
	local regex='[0-9]+(\.[0-9]+)+'

	# Check if command exists
	! command -v "$cmd" &> /dev/null && return 0

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
	esac

	return 0
}

# Return true if the lhs version is strictly older than the rhs
# Returns false if the lhs is the empty string
version_lt() {
	local oldest=$({ echo "$1"; echo "$2"; } | sort -V | head -n 1)
	[ -n "$1" ] && [ "$1" != "$2" ] && [ "$1" = "$oldest" ]
}

# Check that git exists
if ! command -v git &> /dev/null; then
	echo "git: command not found"
	exit 1
fi

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
version=
print_deploy gdb
deploy .config/gdb

if version_lt "$(version_get gdb)" 11.1; then
	deploy_symlink "$XDG_CONFIG_HOME/gdb/gdbinit" "$HOME/.gdbinit"
fi

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
! [ -d "$HOME/.ssh" ] && mkdir --mode 700 "$HOME/.ssh"
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

if version_lt "$(version_get vim)" 9.2; then
	deploy_symlink "$XDG_CONFIG_HOME/vim" "$HOME/.vim"
fi

echo ""

# End of deployment
echo "Deployment completed successfully!"
exit 0
