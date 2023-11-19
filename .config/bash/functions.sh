#!/usr/bin/env bash
#
# Global function definitions

functions()
{

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

# Jump to .git root working tree
gitroot()
{
	local dir=$PWD
	while [ "/" != "$dir" ]; do
		[ -d "${dir}/.git" ] && cd $dir && return 0
		dir=$(dirname "$dir")
	done

	(1>&2 echo "${FUNCNAME}: root working tree not found") && return 1
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

# Override printenv to escape non-printable characters
printenv()
{
	if [ 0 -eq "$#" ]; then
		command printenv | cat -v
	else
		command printenv "$@"
	fi
}

}

functions
unset -f functions
