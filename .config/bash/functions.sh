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
	if grep -vqE "^(.+):[[:digit:]]+$" <<< "$1"; then
		server="${1}:443"
	else
		server="$1"
	fi

	# Get server name if different than url
	name=$([ -n "$2" ] && echo "$2" || (cut -d':' -f 1 <<< "$server"))

	# Get the certificates from the handshake connection of OpenSSL
	openssl s_client -connect "$server" -servername "$name" "$all" \
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
	local binary
	local arch
	local symbols
	local arch_args
	local args

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
	binary="$1"

	if [ -z "$binary" ] || [ -z "$objdump" ]; then
		echo "usage: ${FUNCNAME} [-a ARCH] [-s SYMBOLS] BINARY" >&2
		return 1
	fi

	# Get objdump flavour (GNU or LLVM)
	if $objdump --version | grep -qi gnu; then
		version=gnu
	else
		version=llvm
	fi

	# Get target architecture
	if [ -z "$arch" ]; then
		if file "$binary" | grep -qi x86; then
			arch=x86
		fi
	fi

	# Set parameters
	case "$version" in
		gnu) args=${symbols:+--disassemble="${symbols}"};;
		llvm) args=${symbols:+--disassemble-symbols="${symbols}"};;
	esac

	case "${version}_${arch:-none}" in
		gnu_x86) arch_args=--disassembler-options=intel;;
		llvm_x86) arch_args=--x86-asm-syntax=intel;;
	esac

	$objdump --demangle ${arch_args} ${args:---disassemble} $binary
}

# Handle epoch time
epoch()
{
	local OPTARG
	local OPTIND
	local opts
	local mode="epoch"
	local version
	local date
	local args
	local fmt

	# Parse arguments
	while getopts ":r" opts; do
		case "$opts" in
			r) mode="date";;
			\?) (1>&2 echo "${FUNCNAME}: invalid parameter: -${OPTARG}") && return 1;;
		esac
	done

	shift $((OPTIND - 1))
	date="$1"

	# Get date flavour (GNU or BSD)
	if date --version &> /dev/null; then
		version=gnu
	else
		version=bsd
	fi

	case "${version}_${mode}" in
		gnu_epoch) date -u    ${date:+--date="${date}"}     +"%s";;
		bsd_epoch) date -u -j ${date:+-f "%F %T" "${date}"} +"%s";;
		gnu_date)  date -u    ${date:+--date="@${date}"}    +"%F %T";;
		bsd_date)  date -u -j ${date:+-r "${date}"}         +"%F %T";;
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

# Make directory and cd into it
mkcd()
{
	mkdir "$@" && cd "$_"
}


# Remove dupplicate lines, without sorting
nodup()
{
	cat -n "$@" | sort -k2 -u | sort -k1 -n | cut -f2-
}

}

functions
unset -f functions
