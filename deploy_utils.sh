#!/usr/bin/env bash

shopt -s extglob

deploy_file()
{
	local RES
	local OPTIND OPTARG OPTION
	local MODE NAME
	local SRC DST
	local CHOICE

	while getopts ':m:n:' OPTION; do
		case $OPTION in
			m)
				MODE=$OPTARG
				;;
			n)
				NAME=$OPTARG
				;;
			\?)
				echo "Invalid option: -${OPTARG}" && exit 1
				;;
		esac
	done
	shift $((OPTIND-1))

	[ 1 -ne $# ] && echo "No input file provided" && exit 1

	SRC=$1
	[ ! -f "$SRC" ] && echo "${SRC}: No such file or directory" && exit 1

	DST="${HOME}/${1}"
	if [ -n "$NAME" ]; then
		DST="$(dirname $DST)/${NAME}"
	fi

	echo -n "    ${DST} ... "

	# Destination does not exists
	if [ ! -f "$DST" ]; then
		cp $SRC $DST
		RES=$?; [ 0 -ne $RES ] && exit 1

		if [ -n "$MODE" ]; then
			chmod $MODE $DST
			RES=$?; [ 0 -ne $RES ] && exit 1
		fi

		echo "DEPLOYED"

		return 0
	fi

	# Check diff of the two files
	git diff --no-index --quiet $DST $SRC &> /dev/null
	RES=$?; [ 0 -eq $RES ] && echo "SAME" && return 0

	echo "DIFF"
	while true; do
		# Default choice to yes
		read -p "Do you want to overwrite file '${DST}'? [Y/n/d/q] " CHOICE
		RES=$?; [ 0 -ne $RES ] && echo "" && exit 1
		[ -z "$CHOICE" ] && CHOICE="yes"
		CHOICE=$(echo $CHOICE | tr '[:upper:]' '[:lower:]')

		case $CHOICE in
			y?(es)) # Overwrite file
				cp $SRC $DST
				RES=$?; [ 0 -ne $RES ] && exit 1

				if [ -n "$MODE" ]; then
					chmod $MODE $DST
					RES=$?; [ 0 -ne $RES ] && exit 1
				fi

				echo -n "    ${DST} ... "
				echo "DEPLOYED"
				break
				;;
			n?(o)) # Skip copy
				break
				;;
			d?(iff)) # Display diff and retry
				git diff --no-index $DST $SRC
				;;
			q?(uit)) # Quit the deployment
				exit 0
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
	local OPTIND OPTARG OPTION
	local NAME
	local SRC DST
	local CHOICE

	while getopts ':n:' OPTION; do
		case $OPTION in
			n)
				NAME=$OPTARG
				;;
			\?)
				echo "Invalid option: -${OPTARG}" && exit 1
				;;
		esac
	done
	shift $((OPTIND-1))

	[ 1 -ne $# ] && echo "No input directory provided" && exit 1

	SRC=$1
	[ ! -d "$SRC" ] && echo "${SRC}: No such file or directory" && exit 1

	DST="${HOME}/${1}"
	if [ -n "$NAME" ]; then
		DST="$(dirname $DST)/${NAME}"
	fi

	echo -n "    ${DST} ... "

	# Destination does not exists
	if [ ! -d "$DST" ]; then
		cp -r $SRC $DST
		RES=$?; [ 0 -ne $RES ] && exit 1

		echo "DEPLOYED"

		return 0
	fi

	# Check diff of the two files
	git diff --no-index --quiet $DST $SRC &> /dev/null
	RES=$?; [ 0 -eq $RES ] && echo "SAME" && return 0

	echo "DIFF"
	while true; do
		# Default choice to yes
		read -p "Do you want to replace directory '$(basename ${DST})'? [Y/n/d] " CHOICE
		RES=$?; [ 0 -ne $RES ] && echo "" && exit 1
		[ -z "$CHOICE" ] && CHOICE="yes"
		CHOICE=$(echo $CHOICE | tr '[:upper:]' '[:lower:]')

		case $CHOICE in
			y?(es)) # Replace directory
				rm -rf $DST
				RES=$?; [ 0 -ne $RES ] && exit 1

				cp -r $SRC $DST
				RES=$?; [ 0 -ne $RES ] && exit 1

				echo -n "    ${DST} ... "
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
