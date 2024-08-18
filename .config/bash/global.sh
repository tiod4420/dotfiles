#!/usr/bin/env bash
#
# Global settings

_make_bsdls_colors()
{
	local lscolors

	# Directory
	lscolors+="ex"
	# Symbolic link
	lscolors+="gx"
	# Socket
	lscolors+="dx"
	# Pipe
	lscolors+="bx"
	# Executable
	lscolors+="cx"
	# Block special
	lscolors+="Bx"
	# Character special
	lscolors+="Cx"
	# Executable with setuid bit set
	lscolors+="ab"
	# Executable with setgid bit set
	lscolors+="ad"
	# Directory writable to others, with sticky bit
	lscolors+="ae"
	# Directory writable to others, without sticky bit
	lscolors+="af"

	echo ${lscolors}
}

_make_gcc_colors()
{
	local gcc_colors=(
		"locus=$(get_color -m gcc -o brwhite)"
		"error=$(get_color -m gcc red)"
		"warning=$(get_color -m gcc yellow)"
		"note=$(get_color -m gcc blue)"
		"quote=$(get_color -m gcc green)"
	)

	join_array ":" ${gcc_colors[@]}
}

_make_gnuls_colors()
{
	local dir_colors="${config_dir_path}/dircolors"
	check_has_file "$dir_colors" || dir_colors=""
	dircolors -b ${dir_colors} | sed -n "s/^LS_COLORS='\(.*\)';/\1/p"
}

_setup_linux()
{
	# Setup bash autocomplete
	check_and_source "/usr/share/bash-completion/bash_completion"
	# Try to source git-prompt.sh if not already done
	# Arch Linux
	_bashrc_has_cmd __git_ps1 || check_and_source "/usr/share/git/completion/git-prompt.sh"
	# CentOS
	_bashrc_has_cmd __git_ps1 || check_and_source "/usr/share/git-core/contrib/completion/git-prompt.sh"
	# Debian
	_bashrc_has_cmd __git_ps1 || check_and_source "/usr/lib/git-core/git-sh-prompt"
}

_setup_macos()
{
	# Force fresh path
	if [ -x /usr/libexec/path_helper ]; then
		PATH=""
		eval $(/usr/libexec/path_helper -s)
	fi

	if _bashrc_has_cmd brew; then
		# Setup Homebrew
		_setup_brew
	elif _bashrc_has_cmd /opt/local/bin/port; then
		# Setup MacPorts
		_setup_port
	fi
}

_setup_brew()
{
	local brew_prefix
	local brew_path
	local brew_bin
	local brew_man
	local formula

	# Get Homebrew installation path
	brew_prefix="$(brew --brew_prefix)"

	# Setup bash autocomplete
	check_and_source "${brew_prefix}/opt/bash-completion/etc/profile.d/bash_completion.sh"
	_bashrc_has_cmd __git_ps1 || check_and_source "${brew_prefix}/etc/bash_completion.d/git-prompt.sh"

	# Set Homebrew formulas to PATH and MANPATH
	for formula in "coreutils" "findutils" "gnu-sed" "grep" "openssl"; do
		brew_path="${brew_prefix}/opt/${formula}"

		# Skip if path doesn't exist
		[ ! -d "$brew_path" ] && continue

		brew_bin="${brew_path}/libexec/gnubin"
		[ ! -d "$brew_bin" ] && brew_bin="${brew_path}/bin"

		brew_man="${brew_path}/libexec/gnuman"
		[ ! -d "$brew_man" ] && brew_man="${brew_path}/man"

		# Add only if not already in PATH or MANPATH
		add_path -f "$brew_bin"
		add_man -f "$brew_man"
	done
}

_setup_port()
{
	local port_prefix

	# Set MacPorts installation path
	port_prefix="/opt/local"

	# Setup bash autocomplete
	check_and_source "${port_prefix}/etc/profile.d/bash_completion.sh"
	_bashrc_has_cmd __git_ps1 || check_and_source "${port_prefix}/share/git/contrib/completion/git-prompt.sh"

	# Setup MacPorts PATH
	add_path -f "${port_prefix}/bin"
	add_path -f "${port_prefix}/sbin"
	add_path -f "${port_prefix}/libexec/gnubin"
}

case "$os_type" in
	linux) _setup_linux;;
	macos) _setup_macos;;
esac

# Add Rust development environment to PATH
_bashrc_has_cmd cargo || add_path "${HOME}/.cargo/bin"

# Append to the Bash history file, rather than overwriting it
shopt -s histappend 2> /dev/null
# Doesn't directly use history substitution
shopt -s histverify 2> /dev/null
# Set VI command line editing mode
set -o vi
# Set the binding to vi mode
set keymap vi

# Set language preferences
export LANG="en_US.UTF-8"
# Set locale preferences
export LC_ALL="en_US.UTF-8"

# Set groff options for colored less and man
export GROFF_NO_SGR=1
# Make vim the default editor.
export EDITOR="vim"
# Make less the default pager
export PAGER="less"
# Make less the default man pager
export MANPAGER="less"

# Increase Bash history size
export HISTSIZE="32768"
# Increase Bash history file size
export HISTFILESIZE=$HISTSIZE
# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL="ignoreboth"

# Get number of colors of the terminal
if [ "$term_colors" -ge 256 ]; then
	# Retrieve LS version from here, as path might change during setup
	case "$ls_version" in
		gnu) export LS_COLORS=$(_make_gnuls_colors);;
		bsd) export CLICOLOR=1 LSCOLORS=$(_make_bsdls_colors);;
	esac

	# Set GCC messages colors
	export GCC_COLORS=$(_make_gcc_colors)

	# Set GTest colors
	export GTEST_COLOR=1

	# Set man colors
	export MANPAGER="less -R --use-color -Ddb -Duy -DSkw -DPkw"
fi

unset -f _make_bsdls_colors
unset -f _make_gcc_colors
unset -f _make_gnuls_colors
unset -f _setup_linux
unset -f _setup_macos
unset -f _setup_brew
unset -f _setup_port
