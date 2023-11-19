#!/usr/bin/env bash

shopt -s extglob

# Include utils
source deploy_utils.sh &> /dev/null
RES=$?; [ 0 -ne $RES ] && "deploy_utils.sh: No such file or directory" && exit 1

# Format: major(.minor(.patch))
REGEX_VERSION="s/^\([0-9]\{1,\}\)\(\(\.[0-9]\{1,\}\)\{0,2\}\).*$/\1\2/p"
REGEX_CLANG_FORMAT='s/.*clang-format\sversion\s*\([0-9][0-9]*\.[0-9]*\.[0-9]*\)\s*.*/\1/p'

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
	mkdir -p "${HOME}/.bash.d"
	RES=$?; [ 0 -ne $RES ] && exit 1
	mkdir -p "${HOME}/.bash.d/local"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add bash configuration files
	for FILE in .bash.d/*; do
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
	local FILE NEW_FILE PATCH_FILE
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
		NEW_FILE="clang-format-${i}"
		PATCH_FILE="${NEW_FILE}.patch"

		[ ! -f "${PATCH_FILE}" ] && continue

		patch -N -r /dev/null -o $NEW_FILE $FILE $PATCH_FILE &> /dev/null
		RES=$?; [ 0 -ne $RES ] && exit 1

		FILE=$NEW_FILE
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

	deploy_file .gitconfig
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Create .git.d directory if does not exist
	mkdir -p "${HOME}/.git.d"
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Add git configuration files
	for FILE in .git.d/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

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

	if [ 8 -lt "$MAJOR" ]; then
		deploy_file -n .vimrc-7.0 .vimrc
		RES=$?; [ 0 -ne $RES ] && exit 1

		deploy_dir -n .vim-7.0 .vim
		RES=$?; [ 0 -ne $RES ] && exit 1

		return 0
	fi

	deploy_file .vimrc
	RES=$?; [ 0 -ne $RES ] && exit 1

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

git submodule update --init --recursive --remote
RES=$?; [ 0 -ne $RES ] && exit 1
echo "Updating submodules -- DONE"
echo ""

# Deploy single-file configuration
echo "Deploying dotfiles"
deploy_file .gdbinit
RES=$?; [ 0 -ne $RES ] && exit 1
mkdir -p "${HOME}/.cargo"
RES=$?; [ 0 -ne $RES ] && exit 1
deploy_file .cargo/config.toml
RES=$?; [ 0 -ne $RES ] && exit 1

echo ""

# Deploy multi-files configuration
deploy_bash
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_clang_format
RES=$?; [ 0 -ne $RES ] && exit 1
echo ""

deploy_git
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
