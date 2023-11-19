#!/usr/bin/env bash
#
# Global function definitions

functions()
{

# Encryption function (Encrypt-then-MAC)
encrypt()
{
	local OPTIND
	local ARG="" OPTIONS=""
	local FILE_IN="" FILE_OUT=""
	local PASSWORD="" PASSWORD_FILE=""
	local SALT=""
	local FILE_TMP_ENC="" FILE_TMP_MAC=""
	local PASSWORD_ENC="" PASSWORD_MAC=""
	local RES=1

	# Set traps to remove temporary files
	trap "[ -f \"\$FILE_TMP_ENC\" ] && rm \$FILE_TMP_ENC; \
		[ -f \"\$FILE_TMP_MAC\" ] && rm \$FILE_TMP_MAC" RETURN

	# Parse options
	while getopts ":i:k:o:p:s:" ARG; do
		case $ARG in
			'i')
				FILE_IN=$OPTARG
				;;
			'k')
				PASSWORD=$OPTARG
				;;
			'o')
				FILE_OUT=$OPTARG
				;;
			'p')
				PASSWORD_FILE=$OPTARG
				;;
			's')
				SALT=$OPTARG
				;;
			':')
				echo "${FUNCNAME}: No parameter for -${OPTARG}"
				return 1
				;;
			'?')
				echo "${FUNCNAME}: Unknown command -${OPTARG}"
				return 1
				;;
			*)
				;;
		esac
	done

	# Read password if provided from a file
	if [ -n "$PASSWORD_FILE" ]; then
		# Check that password is not set twice
		if [ -n "$PASSWORD" ]; then
			echo "${FUNCNAME}: password set twice"
			return 1
		fi
		# Read password from file
		PASSWORD=$(cat $PASSWORD_FILE)
		RES=$?; [ 0 -ne "$RES" ] && return $RES
	fi

	# Cannot have no password file and no input file
	if [ -z "$FILE_IN" ] && [ -z "$PASSWORD" ]; then
		return 1
	fi

	# Get password if empty
	if [ -z "$PASSWORD" ]; then
		read -s -p "Enter password: " PASSWORD
		RES=$?; [ 0 -ne "$RES" ] && return $RES
		echo ""
	fi

	# Set actual passwords
	PASSWORD_ENC="${PASSWORD}_ENC"
	PASSWORD_MAC="${PASSWORD}_MAC"

	# Get salt if empty
	if [ -z "$SALT" ]; then
		SALT=$(hexdump -n 8 -e "4/4 \"%08x\"" /dev/random)
		RES=$?; [ 0 -ne "$RES" ] && return $RES
	fi

	# Encrypt input data
	OPTIONS=""
	FILE_TMP_ENC=$(mktemp -p .)
	RES=$?; [ 0 -ne "$RES" ] && return $RES
	[ -n "$FILE_IN" ] && OPTIONS="-in $FILE_IN"
	openssl enc -aes-256-cbc -e -k $PASSWORD_ENC -S $SALT -md sha256 \
		-pbkdf2 -iter 10000 $OPTIONS -out $FILE_TMP_ENC
	RES=$?; [ 0 -ne "$RES" ] && return $RES

	# Compute digest
	FILE_TMP_MAC=$(mktemp -p .)
	RES=$?; [ 0 -ne "$RES" ] && return $RES
	openssl dgst -sha512 -hmac $PASSWORD_MAC -binary \
		$FILE_TMP_ENC > $FILE_TMP_MAC
	RES=$?; [ 0 -ne "$RES" ] && return $RES

	# Concatenate the two files and base64 encode
	OPTIONS=""
	[ -n "$FILE_OUT" ] && OPTIONS="-out $FILE_OUT"
	cat $FILE_TMP_MAC $FILE_TMP_ENC | openssl base64 $OPTIONS
	RES=$?; [ 0 -ne "$RES" ] && return $RES

	return 0
}

# Decryption function (Encrypt-then-MAC)
decrypt()
{
	local OPTIND
	local ARG="" OPTIONS=""
	local FILE_IN="" FILE_OUT=""
	local PASSWORD="" PASSWORD_FILE=""
	local FILE_TMP_ENC="" FILE_TMP_MAC=""
	local PASSWORD_ENC="" PASSWORD_MAC=""
	local RES=1

	# Set traps to remove temporary files
	trap "[ -f \"\$FILE_TMP_ENC\" ] && rm \$FILE_TMP_ENC; \
		[ -f \"\$FILE_TMP_MAC\" ] && rm \$FILE_TMP_MAC" RETURN

	# Parse options
	while getopts ":i:k:o:p:" ARG; do
		case $ARG in
			'i')
				FILE_IN=$OPTARG
				;;
			'k')
				PASSWORD=$OPTARG
				;;
			'o')
				FILE_OUT=$OPTARG
				;;
			'p')
				PASSWORD_FILE=$OPTARG
				;;
			':')
				echo "${FUNCNAME}: No parameter for -${OPTARG}"
				return 1
				;;
			'?')
				echo "${FUNCNAME}: Unknown command -${OPTARG}"
				return 1
				;;
			*)
				;;
		esac
	done

	# Read password if provided from a file
	if [ -n "$PASSWORD_FILE" ]; then
		# Check that password is not set twice
		if [ -n "$PASSWORD" ]; then
			echo "${FUNCNAME}: password set twice"
			return 1
		fi
		# Read password from file
		PASSWORD=$(cat $PASSWORD_FILE)
		RES=$?; [ 0 -ne "$RES" ] && return $RES
	fi

	# Cannot have no password file and no input file
	[ -z "$FILE_IN" ] && [ -z "$PASSWORD" ] && return 1

	# Get password if empty
	if [ -z "$PASSWORD" ]; then
		read -s -p "Enter password: " PASSWORD
		RES=$?; [ 0 -ne "$RES" ] && return $RES
		echo ""
	fi

	# Set actual passwords
	PASSWORD_ENC="${PASSWORD}_ENC"
	PASSWORD_MAC="${PASSWORD}_MAC"

	# base64 decode
	FILE_TMP_MAC=$(mktemp -p .)
	RES=$?; [ 0 -ne "$RES" ] && return $RES
	[ -n "$FILE_IN" ] && OPTIONS="-in $FILE_IN"
	openssl base64 -d $OPTIONS -out $FILE_TMP_MAC
	RES=$?; [ 0 -ne "$RES" ] && return $RES

	# Split the two files
	FILE_TMP_ENC=$(mktemp -p .)
	RES=$?; [ 0 -ne "$RES" ] && return $RES
	tail --bytes=+65 $FILE_TMP_MAC > $FILE_TMP_ENC
	RES=$?; [ 0 -ne "$RES" ] && return $RES
	truncate --size=64 $FILE_TMP_MAC
	RES=$?; [ 0 -ne "$RES" ] && return $RES

	# Check digest
	cmp --silent $FILE_TMP_MAC \
		<(openssl dgst -sha512 -hmac $PASSWORD_MAC -binary \
		$FILE_TMP_ENC)
	RES=$?; [ 0 -ne "$RES" ] && echo "$0: invalid MAC" && return $RES

	# Decrypt input data
	[ -n "$FILE_OUT" ] && OPTIONS="-out $FILE_OUT"
	openssl enc -aes-256-cbc -d -k $PASSWORD_ENC -md sha256 \
		-pbkdf2 -in $FILE_TMP_ENC $OPTIONS
	RES=$?; [ 0 -ne "$RES" ] && return $RES

	return 0
}

# Handle epoch time
epoch()
{
	local date_version

	# Get date version (GNU or BSD)
	date --version &> /dev/null &&
		date_version='gnudate' || date_version='bsddate'

	if [ 0 -eq $# ]; then # Print current epoch
		if [ "gnudate" = "$date_version" ]; then
			date -u +%s
		else
			date -j -u +%s
		fi
	elif [ 1 -eq $# ]; then # Give epoch of given time
		if [ "gnudate" = "$date_version" ]; then
			date -u --date=$1 +%s
		else
			date -u -j -f "%F %T" +%s
		fi
	elif [ "-r" = "$1" ]; then # Reverse epoch of given time
		shift
		if [ "gnudate" = "$date_version" ]; then
			date -u --date="@${1}" +"%F %T"
		else
			date -u -j -r $1 +"%F %T"
		fi
	else # Unknown parameters
		(1>&2 echo "${FUNCNAME}: too many operands") && return 1
	fi
}

# Download a X509 certificate from an URL
cert()
{
	local server name
	local all
	# Certificate delimiters
	local begin="-----BEGIN CERTIFICATE-----"
	local end="-----END CERTIFICATE-----"

	# Check if argument is provided
	[ 0 -eq "$#" ] && return 0

	# Get the full certificate chain or not
	if [ "-a" = "$1" ] || [ "--all" = "$1" ]; then
		all="-showcerts"
		shift
	fi

	# Add default port to 443 if not specified
	if grep -vqE "^(.+):[[:digit:]]+$" <<< $1; then
		server="${1}:443"
	else
		server=$1
	fi

	# Get server name if different than url
	name=$([ -n "$2" ] && echo $2 || (cut -d':' -f 1 <<< ${server}))

	# Get the certificates from the handshake connection of OpenSSL
	openssl s_client -connect "$server" -servername "$name" $all \
		2>&1 <<< "GET / HTTP/1.0\n\n" | sed -ne "/${begin}/,/${end}/p"
}

# Get the size of a file or of a directory
fsize()
{
	local args
	local dir="."

	# Check if argument is provided
	[ 1 -eq "$#" ] && [ -n "$dir" ] && dir=$1

	# Check if -b is supported
	args=$(du -b /dev/null &> /dev/null && echo '-sbh' || echo '-sh')
	# Get the size of the directory or file
	du $args $dir | cut -f 1
}

# Count the number of files of a directory
nfiles()
{
	local dir="."

	# Check if argument is provided
	[ 1 -eq "$#" ] && dir=$1
	# Get the list of files in the given folder and count them
	[ -d "$dir" ] && find $dir -mindepth 1 | wc -l
}

# Count the number of lines in a file or a directory
cloc()
{
	local arg='.'

	# Check if argument is provided
	[ 1 -eq "$#" ] && [ -n "$arg" ] && arg=$1

	if [ -d "$arg" ]; then
		# Get the list of regular files in the given folder
		(find $arg -type f -print0 | xargs -0 cat) | wc -l
	elif [ -f "$arg" ]; then
		# Count the number of files of the argument
		wc -l < $arg
	fi
}

# Search for file in current directory
ff()
{
	# Check if argument is provided
	[ 0 -eq "$#" ] && return 0
	[ 1 -lt "$#" ] && (1>&2 echo "${FUNCNAME}: too many operands") && return 1
	# Search for file execpted .git directory
	find . -name "$1" --exclude-dir=".git" 2> /dev/null
}

# Search for text within the current directory
ft()
{
	# Check if argument is provided
	[ 0 -eq "$#" ] && return 0
	[ 1 -lt "$#" ] && (1>&2 echo "${FUNCNAME}: too many operands") && return 1
	# Search for text excepted .git directory
	grep -R --color=always --exclude-dir=".git" "$1" "." 2> /dev/null | less
}

# Dump a file as a C array
bin2c()
{
	xxd -i $1
}

# Make a hex dump of a file
bin2hex()
{
	xxd -g1 $1
}

# Revert a hex dump
hex2bin()
{
	xxd -r $1
}

}

functions
unset -f functions
