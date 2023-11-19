#!/usr/bin/env bash
#
# Global function definitions

# Update system
update_all()
{
	if [ 'linux' = "$(_os_name)" ]; then
		# Upgrade on Debian-like systems
		which -s apt && apt update && apt upgrade
	elif [ 'osx' = "$(_os_name)" ]; then
		# Upgrade brew
		_has_brew && brew update && brew upgrade && brew cleanup
	fi

	# Upgrade pip2
	which -s pip2 && pip2 install --upgrade pip
	# Upgrade pip3
	which -s pip3 && pip3 install --upgrade pip
	# Update dotfiles
	pushd ~ && git pull && source ~/.bashrc
}

# Delete automatically created files from current folder, recursively
rmrec()
{
	local file

	# Check if any argument is provided
	[ 0 -eq ${#} ] && (1>&2 echo "${FUNCNAME}: missing operand") && return 1

	# Delete files recursively
	for file in ${@}; do
		find . -type f -name "${file}" -ls -delete
	done
}

# Kindof universal extractor
extract()
{
	local file
	local dir='.'

	# Check if argument is provided
	[ ${#} -lt 1 ] && (1>&2 echo "${FUNCNAME}: missing operand") && return 1

	file=${1}
	dir=$([ -n "${2}" ] && echo ${2} || echo '.')

	case $file in
		"*.7z")
			7z e ${file} -o ${dir}
			;;
		"*.jar")
			unzip ${file} -d ${dir}
			;;
		"*.rar")
			unrar x -r ${dir}
			;;
		"*.tar.bz2" | "*.tbz2")
			tar xjvf ${file} -C ${dir}
			;;
		"*.tar.gz" | "*.tgz")
			tar xzvf ${file} -C ${dir}
			;;
		"*.tar.xz" | "*.txz")
			tar xJvf ${file} -C ${dir}
			;;
		"*.zip")
			unzip ${file} -d ${dir}
			;;
		*)
			echo "File format not supported"
			;;
	esac
}

# Handle epoch time
epoch()
{
	local date_version

	# Get date version (GNU or BSD)
	date --version && date_version='gnudate' || date_version='bsddate'

	if [ 0 -eq ${#} ]; then # Print current epoch
		if [ 'gnudate' = "${date_version}" ]; then
			date -u +%s
		else
			date -j -u +%s
		fi
	elif [ 1 -eq ${#} ]; then # Give epoch of given time
		if [ 'gnudate' = "${date_version}" ]; then
			date -u --date="${1}" +%s
		else
			date -u -j -f "%F %T" +%s
		fi
	elif [ 2 -eq ${#} ]; then # Reverse epoch of given time
		if [ 'gnudate' = "${date_version}" ]; then
			date -u --date="@${1}" +"%F %T"
		else
			date -u -j -r ${1} +"%F %T"
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
	local begin='-----BEGIN CERTIFICATE-----'
	local end='-----END CERTIFICATE-----'

	# Get the full certificate chain or not
	if [ '-a' = ${1} ] || [ '--all' = ${1} ]; then
		all='-showcerts'
		shift
	fi

	# Check if argument is provided
	[ ${#} -lt 1 ] && (1>&2 echo "${FUNCNAME}: missing operand") && return 1

	# Add default port to 443 if not specified
	if grep -vqE "^(.+):[[:digit:]]+$" <<< ${1}; then
		server="${1}:443"
	else
		server=${1}
	fi

	# Get server name if different than url
	name=$([ -n "${2}" ] && echo ${2} || (cut -d':' -f 1 <<< ${server}))

	# Get the certificates from the handshake connection of OpenSSL
	openssl s_client -connect "${server}" -servername "${name}" ${all} \
		2>&1 <<< "GET / HTTP/1.0\n\n" | sed -ne "/${begin}/,/${end}/p"
}

# Create a directory and pushd into it
mkpushd()
{
	# Check if argument is provided
	[ 1 -ne ${#} ] && (1>&2 echo "${FUNCNAME}: missing operand") && return 1
	# Create directory and jump into it
	mkdir -p ${1} && pushd ${_}
}

# Get the size of a file or of a directory
fsize()
{
	local args
	local dir='.'

	# Check if argument is provided
	[ 1 -eq ${#} ] && [ -n "${dir}" ] && dir=${1}
	# Check if -b is supported
	args=$(du -b /dev/null > /dev/null 2>&1 && echo '-sbh' || echo '-sh')
	# Get the size of the directory or file
	du ${args} ${dir} | cut -f 1
}

# Count the number of files of a directory
nfiles()
{
	local dir

	# Check if argument is provided
	[ 1 -eq ${#} ] && dir=${1}
	# Get the list of files in the given folder and count them
	[ -d "${dir}" ] && find ${dir} -mindepth 1 | wc -l
}

# Count the number of lines in a file or a directory
cloc()
{
	local arg='.'

	# Check if argument is provided
	[ 1 -eq ${#} ] && [ -n "${arg}" ] && arg=${1}
	# Get the list of regular files in the given folder and count the lines
	[ -d "${arg}" ] && (find ${arg} -type f -print0 | xargs -0 cat) | wc -l
	# Count the number of files of the argument
	[ -f "${arg}" ] && wc -l ${arg}
}
