#!/usr/bin/env bash

shopt -s extglob

DIGIT="[0-9][0-9]*"
REGEX_VERSION="s/^\(${DIGIT}\)\(\(\.${DIGIT}\)*\).*$/\1\2/p"

deploy_file()
{
	local RES
	local SRC
	local DST
	local CHOICE

	[ 1 -ne $# ] && exit 1
	[ ! -f $1 ] && echo "$1: No such file or directory" && exit 1

	SRC=$1
	DST="${HOME}/$1"

	echo -n "    $SRC ... "

	# Destination does not exists
	if [ ! -f "$DST" ]; then
		mv "$SRC" "$DST"
		RES=$?; [ 0 -ne "$RES" ] && exit 1
		echo "DEPLOYED"

		return 0
	fi

	# Check diff of the two files
	git diff --no-index --quiet $DST $SRC
	RES=$?; [ 0 -eq "$RES" ] && echo "SAME" && return 0

	echo "DIFF"
	while true; do
		# Default choice to yes
		read -p "Do you want to overwrite file '$1'? [Y/n/d] " CHOICE
		RES=$?; [ 0 -ne "$RES" ] && echo "" && exit 1
		[ "" = "$CHOICE" ] && CHOICE="yes"
		CHOICE=$(echo $CHOICE | tr '[:upper:]' '[:lower:]')

		case "$CHOICE" in
			y?(es)) # Overwrite file
				cp "$SRC" "$DST"
				RES=$?; [ 0 -ne "$RES" ] && exit 1
				echo -n "    $SRC ... "
				echo "DEPLOYED"
				break
				;;
			n?(o)) # Skip copy
				break
				;;
			d?(iff)) # Display diff and retry
				git diff --no-index $DST $SRC
				;;
			*) # Invalid choice and retry
				echo "Choices are: yes|no|diff"
				;;
		esac
	done

	return 0
}

deploy_dir()
{
	local RES
	local SRC
	local DST
	local CHOICE

	[ 1 -ne $# ] && exit 1
	[ ! -d $1 ] && echo "$1: No such file or directory" && exit 1

	SRC=$1
	DST="${HOME}/$1"

	echo -n "    $SRC ... "

	# Destination does not exists
	if [ ! -d "$DST" ]; then
		mv "$SRC" "$DST"
		RES=$?; [ 0 -ne "$RES" ] && exit 1
		echo "DEPLOYED"

		return 0
	fi

	# Check diff of the two files
	git diff --quiet $DST $SRC 2> /dev/null
	RES=$?; [ 0 -eq "$RES" ] && echo "SAME" && return 0

	echo "DIFF"
	while true; do
		# Default choice to yes
		read -p "Do you want to replace directory '$1'? [Y/n/d] " CHOICE
		RES=$?; [ 0 -ne "$RES" ] && echo "" && exit 1
		[ "" = "$CHOICE" ] && CHOICE="yes"
		CHOICE=$(echo $CHOICE | tr '[:upper:]' '[:lower:]')

		case "$CHOICE" in
			y?(es)) # Replace directory
				rm -rf "$DST"
				RES=$?; [ 0 -ne "$RES" ] && exit 1
				cp -r "$SRC" "$DST"
				RES=$?; [ 0 -ne "$RES" ] && exit 1
				echo -n "    $SRC ... "
				echo "DEPLOYED"
				break
				;;
			n?(o)) # Skip replace
				break
				;;
			d?(iff)) # Display diff and retry
				git diff --no-index $DST $SRC
				;;
			*) # Invalid choice and retry
				echo "Choices are: yes|no|diff"
				;;
		esac
	done

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
		VERSION=$(bash --version | head -n 1 | cut -d ' ' -f 4 | sed -n "${REGEX_VERSION}")
		echo "version ${VERSION}"
	fi

	deploy_file .bash_profile
	RES=$?; [ 0 -ne "$RES" ] && exit 1
	deploy_file .bashrc
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Create .bash.d directory if does not exist
	mkdir -p "${HOME}/.bash.d"
	RES=$?; [ 0 -ne "$RES" ] && exit 1
	mkdir -p "${HOME}/.bash.d/local"
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Add bash configuration files
	for FILE in .bash.d/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne "$RES" ] && exit 1
	done

	return 0
}

deploy_clang_format()
{
	local RES
	local VERSION MAJOR
	local FILE

	echo -n "Deploying clang-format configuration -- "

	if ! command -v clang-format &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(clang-format --version | cut -d ' ' -f 3)
		echo "version ${VERSION}"
	fi

	MAJOR=$(echo ${VERSION} | cut -d '.' -f 1)

	if [ 5 -le "$MAJOR" ]; then
		patch -N -r /dev/null ".clang-format" "clang-format-5.0.patch" &> /dev/null
	fi

	if [ 6 -le "$MAJOR" ]; then
		patch -N -r /dev/null ".clang-format" "clang-format-6.0.patch" &> /dev/null
	fi

	if [ 8 -le "$MAJOR" ]; then
		patch -N -r /dev/null ".clang-format" "clang-format-8.0.patch" &> /dev/null
	fi

	deploy_file .clang-format
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	git restore .clang-format
	RES=$?; [ 0 -ne "$RES" ] && exit 1

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
		VERSION=$(git --version | cut -d ' ' -f 3 | sed -n "${REGEX_VERSION}")
		echo "version ${VERSION}"
	fi

	deploy_file .gitconfig
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Create .git.d directory if does not exist
	mkdir -p "${HOME}/.git.d"
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Add git configuration files
	for FILE in .git.d/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne "$RES" ] && exit 1
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
		VERSION=$(ssh -V 2>&1 | cut -d' ' -f 1 | sed -e 's/^OpenSSH_//' -e 's/,$//' -e 's/p/\./g' | sed -n "${REGEX_VERSION}")
		echo "version ${VERSION}"
	fi

	# Create .ssh directory if does not exist
	mkdir -p "${HOME}/.ssh"
	RES=$?; [ 0 -ne "$RES" ] && exit 1
	chmod 755 "${HOME}/.ssh"
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Add ssh configuration files
	for FILE in .ssh/*; do
		[ ! -f "$FILE" ] && continue

		chmod 600 $FILE
		RES=$?; [ 0 -ne "$RES" ] && exit 1
		deploy_file $FILE
		RES=$?; [ 0 -ne "$RES" ] && exit 1
	done

	return 0
}

deploy_vim()
{
	local RES
	local VERSION MAJOR
	local FILE

	echo -n "Deploying vim configuration -- "

	if ! command -v vim &> /dev/null; then
		VERSION="0.0.0"
		echo "not found"
	else
		VERSION=$(vim --version | head -n 1 | cut -d ' ' -f 5 | sed -n "${REGEX_VERSION}")
		echo "version ${VERSION}"
	fi

	MAJOR=$(echo ${VERSION} | cut -d '.' -f 1)

	if [ 8 -lt "$MAJOR" ]; then
		cp .vimrc-7.0 .vimrc
		RES=$?; [ 0 -ne "$RES" ] && exit 1
		deploy_file .vimrc
		RES=$?; [ 0 -ne "$RES" ] && exit 1

		return 0
	fi

	deploy_file .vimrc
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Create .vim directory if does not exist
	mkdir -p "${HOME}/.vim"
	RES=$?; [ 0 -ne "$RES" ] && exit 1
	mkdir -p "${HOME}/.vim/config"
	RES=$?; [ 0 -ne "$RES" ] && exit 1
	mkdir -p "${HOME}/.vim/config/local"
	RES=$?; [ 0 -ne "$RES" ] && exit 1
	mkdir -p "${HOME}/.vim/pack"
	RES=$?; [ 0 -ne "$RES" ] && exit 1

	# Add vim configuration files
	for FILE in .vim/config/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne "$RES" ] && exit 1
	done

	for PACKAGE in .vim/pack/*; do
		[ ! -d "$PACKAGE" ] && continue

		deploy_dir $PACKAGE
		RES=$?; [ 0 -ne "$RES" ] && exit 1
	done

	return 0
}

# Check that git exists and initialize modules
command -v git &> /dev/null
RES=$?; [ 0 -ne "$RES" ] && echo "git: command not found" && exit 1
echo "Checking git -- FOUND"

git submodule update --init --recursive
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo "Updating submodules -- DONE"
echo ""

# Deploy single files
echo "Deploying dotfiles"
deploy_file .gdbinit
RES=$?; [ 0 -ne "$RES" ] && exit 1
deploy_file .wgetrc
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo ""

# Deploy complex files
deploy_bash
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo ""

deploy_clang_format
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo ""

deploy_git
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo ""

deploy_ssh
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo ""

deploy_vim
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo ""

echo "Deployment completed successfully."

exit 0
