#!/usr/bin/env bash

shopt -s extglob

# Constants
ROOT_DIR=$(dirname ${BASH_SOURCE})
CONFIG_DIR_PATH=${XDG_CONFIG_PATH:-"${HOME}/.config"}
DRY_RUN="false"

# Util functions
deploy_file()
{
	local RES
	local OPTARG OPTIND
	local OPTERR=0
	local opts
	local dir
	local mode
	local file
	local src
	local dst
	local choice

	# Get options
	while getopts "d:f:m:" opts; do
		case "$opts" in
			d) dir=$OPTARG;;
			f) file=$OPTARG;;
			m) mode=$OPTARG;;
			\?) echo "Invalid option: -${OPTARG}" && return 1;;
		esac
	done

	shift $((OPTIND-1))
	[ 1 -ne $# ] && echo "No input file provided" && return 1

	# Set source path
	src="${1}"
	[ ! -f "$src" ] && echo "${src}: No such file or directory" && return 1

	# Set destination path
	if [ -z "$dir" ]; then
		dir="${HOME}/$(dirname ${src})"
	elif [ "/" != "${dir:0:1}" ]; then
		dir="${HOME}/${dir}"
	fi

	if [ -z "$file" ]; then
		file=$(basename ${src})
	elif [ "/" = "${file:0:1}" ]; then
		dir=$(dirname ${file})
		file=$(basename ${file})
	fi

	dst=$(realpath "${dir}/${file}")

	# Deploy file
	if [ ! -f "$dst" ]; then
		# Destination does not exist
		file_copy $src $dst
		RES=$?; [ 0 -ne $RES ] && return 1

		if [ -n "$mode" ]; then
			chmod $mode $dst
			RES=$?; [ 0 -ne $RES ] && return 1
		fi

		file_status "$dst" "DEPLOYED"
	elif git diff --no-index --quiet $dst $src &> /dev/null; then
		# Files are the same
		file_status "$dst" "SAME"
	else
		# Files are different
		file_status "$dst" "DIFF"

		# Get user choice
		read_choice "$src" "$dst"
		RES=$?; [ 0 -ne $RES ] && echo "" && return 1

		if [ "yes" = "$choice" ]; then
			# Replace file
			file_copy $src $dst
			RES=$?; [ 0 -ne $RES ] && return 1

			if [ -n "$mode" ]; then
				chmod $mode $dst
				RES=$?; [ 0 -ne $RES ] && return 1
			fi

			file_status "$dst" "DEPLOYED"
		else
			file_status "$dst" "SKIP"
		fi
	fi

	return 0
}

deploy_dir()
{
	local RES
	local OPTARG OPTIND
	local OPTERR=0
	local opts
	local name
	local src dst
	local choice

	# Get options
	while getopts "n:" opts; do
		case "$opts" in
			n) name=$OPTARG;;
			\?) echo "Invalid option: -${OPTARG}" && return 1;;
		esac
	done

	shift $((OPTIND-1))
	[ 1 -ne $# ] && echo "No input directory provided" && return 1

	# Set source and destination path
	src=$1
	[ ! -d "$src" ] && echo "${src}: No such file or directory" && return 1

	dst="${HOME}/${1}"
	if [ -n "$name" ]; then
		if false; then
			dst=$name
		else
			dst="$(dirname ${dst})/${name}"
		fi
	fi

	# Deploy directory
	if [ ! -d "$dst" ]; then
		# Destination does not exist
		file_copy -r $src $dst
		RES=$?; [ 0 -ne $RES ] && return 1

		file_status "$dst" "DEPLOYED"
	elif git diff --no-index --quiet $dst $src &> /dev/null; then
		# Directories are the same
		file_status "$dst" "SAME"
	else
		# Directories are different
		file_status "$dst" "DIFF"

		# Get user choice
		read_choice "$src" "$dst"
		RES=$?; [ 0 -ne $RES ] && echo "" && return 1

		if [ "yes" = "$choice" ]; then
			# Replace directory
			rm -rf $dst
			RES=$?; [ 0 -ne $RES ] && return 1

			file_copy -r $src $dst
			RES=$?; [ 0 -ne $RES ] && return 1

			file_status "$dst" "DEPLOYED"
		else
			file_status "$dst" "SKIP"
		fi
	fi

	return 0
}

deploy_terminfo()
{
	local RES
	local termname=$1
	local file=$2
	local location

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
	[ "true" != "$DRY_RUN" ] && cp $@ || return 0
}

file_status()
{
	echo "    ${1} ... ${2}"
}

read_choice()
{
	local RES
	local REPLY
	local prompt
	local src=$1
	local dst=$2

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
				git diff --no-index $dst $src
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

version_get()
{
	local prgm=$1
	local d="[0-9]+"

	# Check if command exists
	if ! command -v $prgm &> /dev/null; then
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
	local file

	echo "Deploying alacritty configuration"

	# Create config directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/alacritty"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add alacritty configuration files
	for file in .config/alacritty/*; do
		[ ! -f "$file" ] && continue

		deploy_file $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	deploy_dir .config/alacritty/base16
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_bash()
{
	local RES
	local version
	local file

	echo -n "Deploying bash configuration -- "

	# Get version
	version=$(version_get bash)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Deploy main files in $HOME
	deploy_file .bash_profile
	RES=$?; [ 0 -ne $RES ] && return 1
	deploy_file .bashrc
	RES=$?; [ 0 -ne $RES ] && return 1

	# Create directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/bash"
	RES=$?; [ 0 -ne $RES ] && return 1
	mkdir -p "${CONFIG_DIR_PATH}/bash/local"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add other configuration files
	for file in .config/bash/*; do
		[ ! -f "$file" ] && continue

		deploy_file $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

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

	# Identify highest version that matches
	file=.clang-format

	for i in $(seq ${version%%\.*}); do
		[ -f ".clang-format-${i}" ] && file=".clang-format-${i}"
	done

	# Deploy file
	deploy_file -f .clang-format $file
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_ctags()
{
	local RES

	echo "Deploying ctags configuration"

	# Create ctags directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/ctags"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add alacritty configuration files
	for file in .config/ctags/*; do
		[ ! -f "$file" ] && continue

		deploy_file $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	return 0
}

setup_gdb()
{
	echo "Deploying gdb configuration"

	deploy_file .gdbinit
}

setup_git()
{
	local RES
	local version
	local file

	echo -n "Deploying git configuration -- "

	# Get version
	version=$(version_get git)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Create directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/git"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add git configuration files
	for file in .config/git/*; do
		[ ! -f "$file" ] && continue

		deploy_file $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	return 0
}

setup_rust()
{
	local RES

	echo "Deploying rust configuration"

	# Create cargo directory if does not exist
	mkdir -p "${HOME}/.cargo"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add cargo configuration
	deploy_file .cargo/config.toml
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add rustfmt configuration
	deploy_file .rustfmt.toml
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_ssh()
{
	local RES
	local version
	local file

	echo -n "Deploying ssh configuration -- "

	# Get version
	version=$(version_get ssh)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Create ssh directory if does not exist
	mkdir -p -m 755 "${HOME}/.ssh"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add ssh configuration files
	for file in .ssh/*; do
		[ ! -f "$file" ] && continue

		deploy_file -m 600 $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

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

	# Deploy missing terminfo
	deploy_terminfo alacritty "${ROOT_DIR}/terminfo/alacritty.info"
	RES=$?; [ 0 -ne $RES ] && return 1

	deploy_terminfo alacritty-direct "${ROOT_DIR}/terminfo/alacritty.info"
	RES=$?; [ 0 -ne $RES ] && return 1

	deploy_terminfo tmux-256color "${ROOT_DIR}/terminfo/terminfo.src"
	RES=$?; [ 0 -ne $RES ] && return 1

	return 0
}

setup_tmux()
{
	local RES
	local version
	local dir
	local file

	echo -n "Deploying tmux configuration -- "

	# Get version
	version=$(version_get tmux)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Check if tmux version is less than 2.0
	if version_lt "$version" 2.0; then
		setup_tmux_1
		return
	fi

	# Create config directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/tmux"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Choose configuration directory source
	version_lt "$version" 3.0 && dir=".config/tmux-2" || dir=".config/tmux"
	# Choose main configuration file destination
	version_lt "$version" 3.1 && file=".tmux.conf" || file="${CONFIG_DIR_PATH}/tmux/tmux.conf"

	# Deploy main files in $HOME or .config/tmux
	deploy_file -f ${file} .tmux.conf
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add other configuration files
	for file in ${dir}/*; do
		[ ! -f "$file" ] && continue

		deploy_file -d ".config/tmux/" $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	return 0
}

setup_tmux_1()
{
	deploy_file -f .tmux.conf .tmux-1.conf
}

setup_vim()
{
	local RES
	local version
	local file
	local package

	echo -n "Deploying vim configuration -- "

	# Get version
	version=$(version_get vim)
	[ 0 -eq $? ] && echo "version '${version}'" || echo "not found"

	# Check if vim version is less than 8.0
	if version_lt "$version" 8.0; then
		setup_vim_7
		return
	fi

	# Create .vim directory if does not exist
	mkdir -p "${HOME}/.vim"
	RES=$?; [ 0 -ne $RES ] && return 1
	mkdir -p "${HOME}/.vim/config"
	RES=$?; [ 0 -ne $RES ] && return 1
	mkdir -p "${HOME}/.vim/config/local"
	RES=$?; [ 0 -ne $RES ] && return 1
	mkdir -p "${HOME}/.vim/pack"
	RES=$?; [ 0 -ne $RES ] && return 1

	# Add vim configuration files
	deploy_file .vim/vimrc
	RES=$?; [ 0 -ne $RES ] && return 1

	for file in .vim/config/*; do
		[ ! -f "$file" ] && continue

		deploy_file $file
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	for package in .vim/pack/*; do
		[ ! -d "$package" ] && continue

		deploy_dir $package
		RES=$?; [ 0 -ne $RES ] && return 1
	done

	return 0
}

setup_vim_7()
{
	deploy_dir -n .vim .vim-7
}

# Main script

# Check if is a dry run
[ "-d" = "$1" -o "--dry-run" = "$1" ] && DRY_RUN="true"

# Check that git exists and initialize modules
command -v git &> /dev/null
RES=$?; [ 0 -ne $RES ] && echo "git: command not found" && exit 1
echo "Checking git -- FOUND"

cd ${ROOT_DIR}

git submodule update --init --recursive 2> /dev/null
RES=$?; [ 0 -ne $RES ] && echo "git submodule update: failure" && exit 1
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

setup_ctags
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
