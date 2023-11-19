#!/usr/bin/env bash
#
# Global function definitions

functions()
{

# Download a X509 certificate from an URL
cert()
{
	local server
	local name
	local all
	# Certificate delimiters
	local begin="-----BEGIN CERTIFICATE-----"
	local end="-----END CERTIFICATE-----"

	# Check if argument is provided
	[ 0 -eq "$#" ] && return 0

	# Get the full certificate chain or not
	if [ "-a" = "$1" -o "--all" = "$1" ]; then
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

# Disassemble function
disas()
{
	local version
	local OPTARG
	local OPTIND
	local opts
	local binary
	local symbol

	# Get objdump version (GNU or BSD)
	if objdump --version | grep -qi GNU; then
		version="gnu"
	else
		version="bsd"
	fi

	# Parse arguments
	while getopts ":s:" opts; do
		case "$opts" in
			s) symbol=$OPTARG;;
			\?) (1>&2 echo "${FUNCNAME}: invalid parameter: -${OPTARG}") && return 1;;
		esac
	done

	shift $((OPTIND - 1))
	binary=$1

	if [ -z "$binary" ]; then
		echo "usage: ${FUNCNAME} [-s SYMBOL] BINARY" >&2
		return 1
	fi

	# Setup propery objdump options
	if [ -n "$symbol" ]; then
		if [ "gnu" = "$version" ]; then
			symbol="--disassemble=${symbol}"
		else
			symbol="--disassemble-symbols=${symbol}"
		fi
	fi

	objdump --disassembler-options=intel $symbol $binary
}

# Handle epoch time
epoch()
{
	local version

	# Get date version (GNU or BSD)
	date --version &> /dev/null && version='gnu' || version='bsd'

	if [ 0 -eq $# ]; then # Print current epoch
		if [ "gnu" = "$version" ]; then
			date -u +%s
		else
			date -j -u +%s
		fi
	elif [ 1 -eq $# ]; then # Give epoch of given time
		if [ "gnu" = "$version" ]; then
			date -u --date=$1 +%s
		else
			date -u -j -f "%F %T" +%s
		fi
	elif [ "-r" = "$1" ]; then # Reverse epoch of given time
		shift
		if [ "gnu" = "$version" ]; then
			date -u --date="@${1}" +"%F %T"
		else
			date -u -j -r $1 +"%F %T"
		fi
	else # Unknown parameters
		(1>&2 echo "${FUNCNAME}: too many operands") && return 1
	fi
}

# Jump to .git root working tree
gitroot()
{
	local dir=$PWD
	local found=0

	while [ "/" != "$dir" ]; do
		if [ -d "${dir}/.git" ]; then
			found=1
			break
		fi

		dir=$(dirname "$dir")
	done

	if [ 0 -eq "$found" ]; then
		(1>&2 echo "${FUNCNAME}: root working tree not found")
		return 1
	fi

	pushd $dir
}

# Local HTTP server
http()
{
	if command -v python3 &> /dev/null; then
		python3 -m http.server $1
	elif command -v python2 &> /dev/null; then
		python2 -m SimpleHTTPServer $1
	else
		echo "python2 or python3 is missing"
	fi
}

# Remove dupplicate lines, without sorting
uq()
{
	cat -n "$@" | sort -k2 -u | sort -k1 -n | cut -f2-
}

}

functions
unset -f functions
