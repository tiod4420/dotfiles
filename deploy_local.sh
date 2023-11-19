#!/usr/bin/env bash

shopt -s extglob

# Include utils
source deploy_utils.sh &> /dev/null
RES=$?; [ 0 -ne $RES ] && "deploy_utils.sh: No such file or directory" && exit 1

deploy_conf()
{
	local RES
	local MACHINE
	local FILE

	[ 1 -ne $# ] && echo "No input file provided" && exit 1

	MACHINE=$1
	[ ! -d "$MACHINE" ] && echo "${MACHINE}: No such configuration" && exit 1

	echo "Deploying dotfiles for '${MACHINE}'"

	pushd $MACHINE &> /dev/null
	RES=$?; [ 0 -ne $RES ] && exit 1

	# Deploy single-file configuration
	for FILE in .*; do
		[ ! -f "$FILE" ] && continue

		deploy_file $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	# Deploy multi-files configuration
	for FILE in  .bash.d/local/*; do
		if [ -d "$FILE" ]; then
			deploy_dir $FILE
			RES=$?; [ 0 -ne $RES ] && exit 1
		elif [ -f "$FILE" ]; then
			deploy_file $FILE
			RES=$?; [ 0 -ne $RES ] && exit 1
		fi
	done

	for FILE in  .git.d/*; do
		if [ -d "$FILE" ]; then
			deploy_dir $FILE
			RES=$?; [ 0 -ne $RES ] && exit 1
		elif [ -f "$FILE" ]; then
			deploy_file $FILE
			RES=$?; [ 0 -ne $RES ] && exit 1
		fi
	done

	for FILE in  .ssh/*; do
		[ ! -f "$FILE" ] && continue

		deploy_file -m 600 $FILE
		RES=$?; [ 0 -ne $RES ] && exit 1
	done

	for FILE in  .vim/config/local*; do
		if [ -d "$FILE" ]; then
			deploy_dir $FILE
			RES=$?; [ 0 -ne $RES ] && exit 1
		elif [ -f "$FILE" ]; then
			deploy_file $FILE
			RES=$?; [ 0 -ne $RES ] && exit 1
		fi
	done

	popd &> /dev/null
	RES=$?; [ 0 -ne $RES ] && exit 1

	return 0
}

# Move into local directory
cd local &> /dev/null
RES=$?; [ 0 -ne $RES ] && echo "local: No such file or directory" && exit 1

# Get machine name
[ 2 -le $# ] && echo "usage: ${BASH_SOURCE} [HOSTNAME]" && exit 1

MACHINES=('all')
[ -n "$1" ] && [ "all" != "$1" ] && MACHINES+=("$1")

# Check that git exists and initialize modules
command -v git &> /dev/null
RES=$?; [ 0 -ne "$RES" ] && echo "git: command not found" && exit 1
echo "Checking git -- FOUND"

git submodule update --init --recursive
RES=$?; [ 0 -ne "$RES" ] && exit 1
echo "Updating submodules -- DONE"

echo "Deploying dotfiles for -- ${MACHINES[@]}"
echo ""

# Deploy configuration
for MACHINE in ${MACHINES[@]}; do
	deploy_conf $MACHINE
	RES=$?; [ 0 -ne $RES ] && exit 1
	echo ""
done

echo "Deployment completed successfully."

exit 0
