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
	local OPTARG
	local OPTIND
	local opts
	local objdump
	local version
	local arch
	local binary
	local symbols
	local options

	# Set objdump binary
	objdump=objdump
	[ -n "$OBJDUMP" ] && objdump=$OBJDUMP

	# Parse arguments
	while getopts ":a:s:" opts; do
		case "$opts" in
			a) arch=$OPTARG;;
			s) symbols=$OPTARG;;
			\?) (1>&2 echo "${FUNCNAME}: invalid parameter: -${OPTARG}") && return 1;;
		esac
	done

	shift $((OPTIND - 1))
	binary=$1

	if [ -z "$binary" ] || [ -z "$objdump" ]; then
		echo "usage: ${FUNCNAME} [-a ARCH] [-s SYMBOLS] BINARY" >&2
		return 1
	fi

	# Get objdump flavour
	if $objdump --version | grep -qi gnu; then
		version=gnu
	else
		version=llvm
	fi

	# Get target architecture
	if [ -z "$arch" ]; then
		if file binary | grep -qi x86; then
			arch=x86
		fi
	fi

	# Set disassemble options
	if [ -n "$symbols" ]; then
		case $version in
			gnu) options+="--disassemble=${symbols}";;
			llvm) options+="--disassemble-symbols=${symbols}";;
		esac
	fi

	# Set x86 assembly flavour to Intel
	if [ "x86" = "$arch" ]; then
		case $version in
			gnu) options+=" --disassembler-options=intel";;
			llvm) options+=" --x86-asm-syntax=intel";;
		esac
	fi

	$objdump --demangle --disassemble $options $binary
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
		echo "${FUNCNAME}: too many operands" >&2
		return 1
	fi
}

# Extract usual archive formats
extr()
{
	if [ ! -f "$1" ]; then
		echo "${FUNCNAME}: '${1}' is not a regular file" >&2
		return 1
	fi

	case $1 in
		*.tar.gz)  tar xzvf $1;;
		*.tgz)     tar xzvf $1;;
		*.tar.bz2) tar xjvf $1;;
		*.tbz2)    tar xjvf $1;;
		*.tar)     tar xvf $1;;
		*.bz2)     bunzip2 $1;;
		*.gz)      gunzip $1;;
		*.Z)       uncompress $1;;
		*.rar)     unrar e $1;;
		*.zip)     unzip $1;;
		*.7z)      7z x $1;;
		*)         (1>&2 echo "${FUNCNAME}: '${1}' has unknown extraction method") && return 1;;
	esac
}

# Jump to .git root working tree
gitroot()
{
	local dir
	local res

	dir=$(git rev-parse --show-toplevel 2> /dev/null)
	res=$?

	if [ 0 -ne $res ]; then
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
		echo "${FUNCNAME}: python2 or python3 is missing" >&2
		return 1
	fi
}

# Make a tar archive
mktar()
{
	local dst

	if [ ! -f "$1" -a ! -d "$1" ]; then
		echo "${FUNCNAME}: '${1}' is not a regular file or directory" >&2
		return 1
	fi

	dst=$(basename $1)

	# Strip file extensions if regular file
	if [ -f "$1" ]; then
		dst=${dst%%.*}
	fi

	tar czvf "${dst}.tar.gz" $1
}

# Remove dupplicate lines, without sorting
uq()
{
	cat -n "$@" | sort -k2 -u | sort -k1 -n | cut -f2-
}

}

functions
unset -f functions
