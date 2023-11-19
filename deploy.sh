#!/usr/bin/env bash

shopt -s extglob

ROOT_DIR=$(dirname ${BASH_SOURCE})

if [ -n "$XDG_CONFIG_HOME" ]; then
	CONFIG_DIR_PATH=${XDG_CONFIG_HOME}
else
	CONFIG_DIR_PATH="${HOME}/.config"
fi

# Include utils
if [ ! -f "${ROOT_DIR}/deploy_utils.sh" ]; then
	echo "deploy_utils.sh: No such file or directory"
	exit 1
fi

source ${ROOT_DIR}/deploy_utils.sh &> /dev/null
RES=$?; [ 0 -ne $RES ] && exit 1

# Format: major(.minor(.patch))
REGEX_VERSION="s/^\([0-9]\{1,\}\)\(\(\.[0-9]\{1,\}\)\{0,2\}\).*$/\1\2/p"
REGEX_CLANG_FORMAT='s/.*clang-format\sversion\s*\([0-9][0-9]*\.[0-9]*\.[0-9]*\)\s*.*/\1/p'

deploy_alacritty()
{
	local RES

	echo "Deploying alacritty configuration -- "

	# Create config directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/alacritty"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add alacritty configuration files
	for FILE in .config/alacritty/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	deploy_dir .config/alacritty/base16
	RES=$?; [ 0 -ne $RES ] && exit 1

	return 0
}

deploy_bash()
{
	local RES
	local VERSION
	local FILE

	echo -n "Deploying bash configuration -- "

	if ! command -v bash &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(bash --version | head -n 1 | cut -d ' ' -f 4 | sed -n $REGEX_VERSION)
		echo "version '${VERSION}'"
	fi

	deploy_file .bash_profile
	RES=$?; [ 0 -ne $RES ] && exit 1
	deploy_file .bashrc
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Create .bash.d directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/bash"
	RES=$?; [ 0 -ne $RES ] && exit 1
	mkdir -p "${CONFIG_DIR_PATH}/bash/local"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add bash configuration files
	for FILE in .config/bash/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	return 0
}

deploy_clang_format()
{
	local RES
	local VERSION MAJOR
	local FILE
	local i

	echo -n "Deploying clang-format configuration -- "

	if ! command -v clang-format &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(clang-format --version | head -n 1 | sed -n $REGEX_CLANG_FORMAT)
		echo "version '${VERSION}'"
	fi

	MAJOR=$(echo $VERSION | cut -d '.' -f 1)
	FILE=.clang-format

	for i in $(seq "$MAJOR"); do
		if [ -f ".clang-format-${i}" ]; then
			FILE=".clang-format-${i}"
		fi
	done

	deploy_file -n .clang-format $FILE
	RES=$?; [ 0 -ne $RES ] && exit 1

	return 0
}

deploy_git()
{
	local RES
	local VERSION
	local FILE

	echo -n "Deploying git configuration -- "

	if ! command -v git &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(git --version | cut -d ' ' -f 3 | sed -n $REGEX_VERSION)
		echo "version '${VERSION}'"
	fi

	# Create .git.d directory if does not exist
	mkdir -p "${CONFIG_DIR_PATH}/git"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add git configuration files
	for FILE in .config/git/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	return 0
}

deploy_rust()
{
	local RES

	echo "Deploying rust configuration -- "

	# Create cargo directory if does not exist
	mkdir -p "${HOME}/.cargo"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add cargo configuration
	deploy_file .cargo/config.toml
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add rustfmt configuration
	deploy_file .rustfmt.toml
	RES=$?; [ 0 -ne $RES ] && exit 1

	return 0
}

deploy_ssh()
{
	local RES
	local VERSION
	local FILE

	echo -n "Deploying ssh configuration -- "

	if ! command -v ssh &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(ssh -V 2>&1 | cut -d' ' -f 1 | sed -e 's/^OpenSSH_//' -e 's/,$//' -e 's/p/\./g' | sed -n $REGEX_VERSION)
		echo "version '${VERSION}'"
	fi

	# Create .ssh directory if does not exist
	mkdir -p -m 755 "${HOME}/.ssh"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add ssh configuration files
	for FILE in .ssh/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file -m 600 $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	return 0
}

deploy_vim()
{
	local RES
	local VERSION MAJOR
	local FILE PACKAGE

	echo -n "Deploying vim configuration -- "

	if ! command -v vim &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(vim --version | head -n 1 | cut -d ' ' -f 5 | sed -n $REGEX_VERSION)
		echo "version '${VERSION}'"
	fi

	MAJOR=$(echo $VERSION | cut -d '.' -f 1)

	if [ 8 -gt "$MAJOR" ]; then
		deploy_dir -n .vim .vim-7.0
		RES=$?; [ 0 -ne $RES ] && exit 1

		return 0
	fi

	# Create .vim directory if does not exist
	mkdir -p "${HOME}/.vim"
	RES=$?; [ 0 -ne $RES ] && exit 1
	mkdir -p "${HOME}/.vim/config"
	RES=$?; [ 0 -ne $RES ] && exit 1
	mkdir -p "${HOME}/.vim/config/local"
	RES=$?; [ 0 -ne $RES ] && exit 1
	mkdir -p "${HOME}/.vim/pack"
	RES=$?; [ 0 -ne $RES ] && exit 1


	# Add vim configuration files
	deploy_file .vim/vimrc
	RES=$?; [ 0 -ne $RES ] && exit 1

	for FILE in .vim/config/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	for PACKAGE in .vim/pack/*; do
		[ ! -d "$PACKAGE" ] && continue

		deploy_dir $PACKAGE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	return 0
}

# Check that git exists and initialize modules
command -v git &> /dev/null
RES=$?; [ 0 -ne $RES ] && echo "git: command not found" && exit 1
echo "Checking git -- FOUND"

git submodule update --init --recursive
RES=$?; [ 0 -ne $RES ] && exit 1
echo "Updating submodules -- DONE"
echo ""

# Deploy single-file configuration
echo "Deploying dotfiles"
deploy_file .gdbinit
RES=$?; [ 0 -ne $RES ] && exit 1
deploy_dir .terminfo/
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

# Deploy multi-files configuration
deploy_alacritty
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_bash
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_clang_format
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_git
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_rust
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_ssh
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_vim
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

echo "Deployment completed successfully."

exit 0
