#!/usr/bin/env bash
#
# Global environment variables settings

exports()
{
	# Set language preferences
	export LANG="en_US.UTF-8";
	# Set locale preferences
	export LC_ALL="en_US.UTF-8";

	# Set groff options for colored less and man
	export GROFF_NO_SGR=1
	# Make vim the default editor.
	export EDITOR="vim"
	# Make less the default pager
	export PAGER="less"
	# Make less the default man pager
	export MANPAGER="less"

	# Increase Bash history size
	export HISTSIZE="32768";
	# Increase Bash history file size
	export HISTFILESIZE=$HISTSIZE;
	# Omit duplicates and commands that begin with a space from history.
	export HISTCONTROL="ignoreboth";

	# Get number of colors of the terminal
	if [ "$TERM_COLORS" -ge 256 ]; then
		# Retrieve LS version from here, as path might change during setup
		local ls_version=$(get_ls_version)
		[ "gnuls" = "${ls_version}" ] && export LS_COLORS=$(make_gnuls_colors)
		[ "bsdls" = "${ls_version}" ] && export CLICOLOR=1 LSCOLORS=$(make_bsdls_colors)

		# Set GCC messages colors
		export GCC_COLORS=$(make_gcc_colors)

		# Set GTest colors
		export GTEST_COLOR=1

		# Export less color codes, for colored manpages
		# Start blink -- unused
		export LESS_TERMCAP_mb=$(get_color -e reset)
		# Start bold -- section titles
		export LESS_TERMCAP_md=$(get_color -e blue)
		# End blink, bold, and underline
		export LESS_TERMCAP_me=$(get_color -e reset)
		# End standout
		export LESS_TERMCAP_se=$(get_color -e reset)
		# Start standout -- bottom bar
		export LESS_TERMCAP_so=$(get_color -e reverse)
		# End underline
		export LESS_TERMCAP_ue=$(get_color -e reset)
		# Start underline -- parameters, keywords
		export LESS_TERMCAP_us=$(get_color -e yellow)
	fi
}

make_gnuls_colors()
{
	local dir_colors="${CONFIG_DIR_PATH}/dircolors"
	check_file "$dir_colors" || dir_colors=""
	dircolors -b ${dir_colors} | sed -n "s/^LS_COLORS='\(.*\)';/\1/p"
}

make_bsdls_colors()
{
	local lscolors

	# Directory
	lscolors+="ex"
	# Symbolic link
	lscolors+="gx"
	# Socket
	lscolors+="fx"
	# Pipe
	lscolors+="dx"
	# Executable
	lscolors+="cx"
	# Block special
	lscolors+="Gx"
	# Character special
	lscolors+="Dx"
	# Executable with setuid bit set
	lscolors+="xB"
	# Executable with setgid bit set
	lscolors+="xe"
	# Directory writable to others, with sticky bit
	lscolors+="xc"
	# Directory writable to others, without sticky bit
	lscolors+="xd"

	echo ${lscolors}
}

make_gcc_colors()
{
	local gcc_colors=(
		"locus=$(get_color -m raw -o brwhite)"
		"error=$(get_color -m raw red)"
		"warning=$(get_color -m raw yellow)"
		"note=$(get_color -m raw blue)"
		"quote=$(get_color -m raw green)"
	)

	join_array ":" ${gcc_colors[@]}
}

exports
unset -f exports
unset -f make_gnuls_colors make_bsdls_colors make_gcc_colors
