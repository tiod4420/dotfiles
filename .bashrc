#!/usr/bin/env bash
#
# Bash configuration for interactive non-login shells

# Define some utility functions

# Check permissions on a regular file
_file_check()
{
	local file_path flags
	local i

	[ 1 -ne ${#} ] && [ 2 -ne ${#} ] && return 1

	file_path=${1}
	[ ! -f "${file_path}" ] && return 1

	[ 2 -eq ${#} ] && flags=${2} || flags="r"
	[ -z "${flags}" ] && return 1

	for i in $(seq 1 ${#flags}); do
		case ${flags:i-1:1} in
			"r") [ ! -r "${file_path}" ] && return 1;;
			"w") [ ! -w "${file_path}" ] && return 1;;
			"x") [ ! -x "${file_path}" ] && return 1;;
			*) return 1;;
		esac
	done

	return 0
}

_check_and_source()
{
	[ 1 -ne ${#} ] && return 1
	_file_check ${1} "r" && source ${1}
}

# Check OS family
_os_name()
{
	# Check OS name
	case $(uname | tr '[:upper:]' '[:lower:]') in
		linux*) echo 'linux';;
		darwin*) echo 'osx';;
		freebsd*) echo 'freebsd';;
		msys*) echo 'windows';;
		*) echo 'unknown';;
	esac
}

# Check ls familty
_ls_type()
{
	# Check if --color is supported (GNU ls)
	ls --color -d . > /dev/null 2>&1 && echo 'gnuls' && return 0
	# Check if -G is supported (BSD ls)
	ls -G -d . > /dev/null 2>&1 && echo 'bsdls' && return 0
	# Unknown result
	echo 'unknown'
	return 1
}

# Check if the system has brew installed
_has_brew()
{
	# Check if brew is in the path
	which -s brew
}

# Check if the system has color support
_has_colors()
{
	# Check that we are in a terminal
	[ ! -t 1 ] && return 1
	# Check the number of supported colors
	[ $(tput colors) -lt 256 ] && return 1
	return 0
}

_config_path="${HOME}/.bashrc.d"

# Source all the configuration files
for _file in global.sh exports.sh functions.sh aliases.sh prompt.sh; do
	_check_and_source "${_config_path}/${_file}"
done
unset _file

# Source extra configuration files, not versionized
for _file in "${_config_path}/extra/*.sh"; do
	# Fast check in case directory is empty
	[ ! -f "${_file}" ] && break
	_check_and_source ${_file}
done
unset _file

unset _config_path
unset _check_and_source _file_check
unset _os_name _ls_type _has_brew _has_colors
