#!/usr/bin/env bash

shopt -s extglob

# Constants

CONFIG_DIR_PATH=${XDG_CONFIG_HOME:-${HOME}/.config}
DRY_RUN="false"

# Util functions

deploy()
{
	local RES
	local OPTARG
	local OPTIND
	local check="f"
	local is_config="false"
	local target
	local src_dir
	local dst_dir
	local src
	local dst

	# Get parameters
	while getopts ":cd" opts; do
		case "$opts" in
			c) is_config="true";;
			d) check="d";;
			\?) echo "Invalid option: -${OPTARG}" && exit 1;;
		esac
	done

	shift $((OPTIND - 1))

	[ -n "$1" ] && target="$1" || return 1

	# Set source and destination directories
	if [ "true" = "$is_config" ]; then
		src_dir=".config/${target}"
		dst_dir="${CONFIG_DIR_PATH}/${target}"
	else
		src_dir="${target}"
		dst_dir="${HOME}/${target}"
	fi

	# Create directory
	mkdir -p "${dst_dir}"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Deploy files
	for src in ${src_dir}/*; do
		# Check if source is file or dir
		! [ -${check} "$src" ] && continue

		# Set destination file
		if [ "true" = "$is_config" ]; then
			dst="${dst_dir}/${src##*/}"
		else
			dst="${HOME}/${src}"
		fi

		# Deploy
		deploy_target "$src" "$dst"
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	return 0
}

deploy_target()
{
	local RES
	local src
	local dst
	local choice

	# Get parameters
	[ -n "$1" ] && src="$1" || return 1
	[ -n "$2" ] && dst="$2" || dst="${HOME}/${src}"

	# Deploy file
	if ! target_exists "$src" "$dst"; then
		# Destination does not exist
		file_copy "$src" "$dst"
		RES=$?; [ 0 -ne $RES ] && return 1

		file_status "$dst" "DEPLOYED"
	elif ! git diff --no-index --quiet $dst $src &> /dev/null; then
		# Files are different
		file_status "$dst" "DIFF"

		# Get user choice
		read_choice "$src" "$dst"
		RES=$?; [ 0 -ne $RES ] && echo "" && return 1

		if [ "yes" = "$choice" ]; then
			# Replace file
			file_copy "$src" "$dst"
			RES=$?; [ 0 -ne $RES ] && return 1

			file_status "$dst" "DEPLOYED"
		else
			file_status "$dst" "SKIP"
		fi
	else
		# Files are the same
		file_status "$dst" "SAME"
	fi

	return 0
}

deploy_terminfo()
{
	local RES
	local termname
	local file
	local location

	[ -n "$1" ] && termname="$1" || return 1
	[ -n "$2" ] && file="$2" || return 1

	location=$(find "${HOME}/.terminfo" -name "$termname" 2> /dev/null)

	if [ -n "$location" ]; then
		# Terminfo is installed by the user
		file_status "$termname" "SKIP"
	elif infocmp "$termname" &> /dev/null; then
		# Terminfo is installed by the system
		file_status "$termname" "SKIP"
	else
		# Terminfo is not installed
		tic -xe "$termname" "$file"
		RES=$?; [ 0 -ne $RES ] && return 1

		file_status "$termname" "DEPLOYED"
	fi

	return 0
}

file_copy()
{
	local RES
	local src
	local dst

	# Get parameters
	[ -n "$1" ] && src="$1" || return 1
	[ -n "$2" ] && dst="$2" || return 1

	if [ "true" != "$DRY_RUN" ]; then
		if [ -f "$src" ]; then
			# Copy file
			cp "$src" "$dst"
			RES=$?; [ 0 -ne $RES ] && exit 1
		else
			# Remove existing directory
			if [ -d "$dst" ]; then
				rm -rf "$dst"
				RES=$?; [ 0 -ne $RES ] && return 1
			fi

			# Copy directory
			cp -r "$src" "$dst"
			RES=$?; [ 0 -ne $RES ] && return 1
		fi
	fi

	return 0
}

file_status()
{
	echo "    ${1} ... ${2}"
}

os_type_get ()
{
	case "$(uname | tr "[:upper:]" "[:lower:]")" in
		linux*) echo "linux" ;;
		darwin*) echo "macos" ;;
		freebsd*) echo "freebsd" ;;
		msys*) echo "windows" ;;
		*) echo "unknown" ;;
	esac
}

read_choice()
{
	local RES
	local src
	local dst
	local reply
	local prompt

	# Get parameters
	[ -n "$1" ] && src="$1" || return 1
	[ -n "$2" ] && dst="$2" || return 1

	# Get choice
	[ -f "$src" ] && prompt="overwrite file" || prompt="replace directory"

	choice=""
	while [ -z "$choice" ]; do
		# Default choice to no
		read -p "Do you want to ${prompt} '$(basename ${dst})'? [y/N/d/q] "
		RES=$?; [ 0 -ne $RES ] && echo "" && return 1
		[ -n "$REPLY" ] && REPLY=${REPLY,,} || REPLY="no"

		case "$REPLY" in
			y?(es)) choice="yes";;
			n?(o)) choice="no";;
			d?(iff))
				# Display diff and retry
				git diff --no-index "$dst" "$src"
				choice=""
				;;
			q?(uit))
				# Quit deployment
				exit 0
				;;
			*)
				# Invalid choice and retry
				echo "Choices are: yes|no|diff|quit"
				choice=""
				;;
		esac
	done
}

target_exists()
{
	local src
	local dst

	# Get parameters
	[ -n "$1" ] && src="$1" || return 1
	[ -n "$2" ] && dst="$2" || return 1

	# Check if destination exists according to source type
	if [ -f "$src" ]; then
		[ -f "$dst" ]
	else
		[ -d "$dst" ]
	fi
}

version_get()
{
	local d="[0-9]+"
	local prgm

	# Get parameters
	[ -n "$1" ] && prgm="$1" || return 1

	# Check if command exists
	if ! command -v "$prgm" &> /dev/null; then
		return 1
	fi

	# Extract version
	case "$prgm" in
		bash)
			bash -c 'echo $BASH_VERSION' | sed -E "s/.*(${d})\.(${d})\.(${d}).*/\1.\2.\3/"
			;;
		clang-format)
			clang-format --version | sed -E "s/.*clang-format version (${d})\.(${d})\.(${d}).*/\1.\2.\3/"
			;;
		gdb)
			gdb --version | head -n 1 | sed -E "s/.*\(.*\) (${d})\.(${d}).*/\1.\2/"
			;;
		git)
			git --version | sed -E "s/.*git version (${d})\.(${d})\.(${d}).*/\1.\2.\3/"
			;;
		infocmp)
			infocmp -V | sed -E "s/.*ncurses (${d})\.(${d})\.(${d}).*/\1.\2.\3/"
			;;
		ssh)
			ssh -V 2>&1 | sed -E "s/.*OpenSSH_(${d})\.(${d})p(${d}).*/\1.\2p\3/"
			;;
		tmux)
			tmux -V | sed -E "s/.*tmux (${d})\.(${d}).*/\1.\2/"
			;;
		vim)
			vim --version | head -n 1 | sed -E "s/.*VIM - Vi IMproved (${d})\.(${d}).*/\1.\2/"
			;;
		*)
			echo "0.0.0"
			;;
	esac
}

version_lt()
{
	[ "$(echo -e "$1\n$2" | sort -V -r | head -n 1)" != "$1" ]
}

# Deploy functions

setup_alacritty()
{
	local RES

	echo "Deploying alacritty configuration"

	# Deploy configuration
	deploy -c alacritty
	RES=$?; [ 0 -ne $RES ] && exit 1

	return 0
}

setup_bash()
{
	local RES
	local version

	echo -n "Deploying bash configuration -- "

	# Get version
	version=$(version_get bash)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy main files in $HOME
	deploy_target .bash_profile
	RES=$?; [ 0 -ne $RES ] && return 1
	deploy_target .bashrc
	RES=$?; [ 0 -ne $RES ] && return 1

	# Deploy configuration
	deploy -c bash
	RES=$?; [ 0 -ne $RES ] && return 1

	# Create local configuration directory
	mkdir -p "${CONFIG_DIR_PATH}/bash/local"
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_clang_format()
{
	local RES
	local version
	local file
	local i

	echo -n "Deploying clang-format configuration -- "

	# Get version
	version=$(version_get clang-format)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy configuration
	deploy_target .clang-format "${HOME}/.clang-format"
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_gdb()
{
	local RES
	local version

	echo -n "Deploying gdb configuration"

	# Get version
	version=$(version_get gdb)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy configuration
	if version_lt "$version" 11.1; then
		deploy_target .config/gdb/gdbinit "${HOME}/.gdbinit"
		RES=$?; [ 0 -ne $RES ] && return 1
	else
		deploy -c gdb
		RES=$?; [ 0 -ne $RES ] && return 1
	fi

	return 0
}

setup_git()
{
	local RES
	local version

	echo -n "Deploying git configuration -- "

	# Get version
	version=$(version_get git)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy configuration
	deploy -c git
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_rust()
{
	local RES
	local os

	echo "Deploying rust configuration"

	# Get OS type
	os=$(os_type_get)

	# Deploy cargo configuration
	mkdir -p "${HOME}/.cargo"
	RES=$?; [ 0 -ne $RES ] && return 1

	deploy_target .cargo/config.toml
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_ssh()
{
	local RES
	local version

	echo -n "Deploying ssh configuration -- "

	# Get version
	version=$(version_get ssh)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy configuration
	deploy .ssh
	RES=$?; [ 0 -ne $RES ] && return 1

	# Set file permissions
	chmod 600 ${HOME}/.ssh/*
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_terminfo()
{
	local RES
	local version

	echo -n "Deploying terminfo -- "

	# Get version
	version=$(version_get infocmp)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Short circuit setup of terminfo if ncurses is not installed
	[ -z "$version" ] && return 0

	# Deploy missing terminfo files
	deploy_terminfo alacritty terminfo/alacritty.info
	RES=$?; [ 0 -ne $RES ] && return 1

	deploy_terminfo alacritty-direct terminfo/alacritty.info
	RES=$?; [ 0 -ne $RES ] && return 1

	deploy_terminfo tmux-256color terminfo/terminfo.src
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_tmux()
{
	local RES
	local version
	local dir

	echo -n "Deploying tmux configuration -- "

	# Get version
	version=$(version_get tmux)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy configuration
	deploy -c tmux
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_vim()
{
	local RES
	local version

	echo -n "Deploying vim configuration -- "

	# Get version
	version=$(version_get vim)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy vimrc
	mkdir -p "${HOME}/.vim"
	RES=$?; [ 0 -ne $RES ] && return 1

	deploy_target .vim/vimrc
	RES=$?; [ 0 -ne $RES ] && return 1

	# Deploy configuration
	deploy .vim/config
	RES=$?; [ 0 -ne $RES ] && return 1

	# Create local configuration directory
	mkdir -p "${HOME}/.vim/config/local"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Deploy plugins
	deploy -d .vim/pack
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

# Main script

# Check if is a dry run
if [ "-d" = "$1" ] || [ "--dry-run" = "$1" ]; then
	DRY_RUN="true"
fi

# Check that git exists and initialize modules
command -v git &> /dev/null
RES=$?; [ 0 -ne $RES ] && echo "git: command not found" && exit 1
echo "Checking git -- FOUND"

cd $(dirname ${BASH_SOURCE})
RES=$?; [ 0 -ne $RES ] && exit 1

git submodule update --init --recursive
RES=$?; [ 0 -ne $RES ] && exit 1
echo "Updating submodules -- DONE"
echo ""

# Deploy configurations
setup_alacritty
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_bash
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_clang_format
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_gdb
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_git
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_rust
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_ssh
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_terminfo
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_tmux
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

setup_vim
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

echo "Deployment completed successfully."

exit 0
