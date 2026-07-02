#!/usr/bin/env bash
#
# Global and environment variable settings

# Readline editing mode as vi
set -o vi

# Locale
export LANG=en_US.UTF-8

# Default programs
export BROWSER=firefox
export EDITOR=vim
export MANPAGER=less
export PAGER=less
export VISUAL=vim

# History settings
export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export HISTIGNORE="clear:exit:ls:ll:ls -l:la:ls -la:tree:bg:fg:cd:..:cd ..:popd"
# Append history to the file, to avoid parallel shells erasing each other
shopt -s histappend 2> /dev/null
# History substitutions are not executed directly, but added to the line
shopt -s histverify 2> /dev/null

# Try to source bash-completion (source it after setting LANG for macOS)
if [ -z "$BASH_COMPLETION_VERSINFO" ]; then
	for file in "${_BASHRC_BASH_COMPLETION[@]}"; do
		_bashrc_try_source "$file" && break
	done
fi

# Android SDK path
for dir in "${_BASHRC_ANDROID_HOME[@]}"; do
	[ -d "$dir" ] && export ANDROID_HOME=$dir && break
done

# Export locales for colors
if _bashrc_has_colors; then
	# ls colors
	eval $(dircolors -b "$(dirname "${BASH_SOURCE[0]}")/dircolors.db")

	# gcc colors
	GCC_COLORS=""
	GCC_COLORS+="locus=${_BASHRC_COLORS[bold]};${_BASHRC_COLORS[brwhite]}"
	GCC_COLORS+=":error=${_BASHRC_COLORS[red]}"
	GCC_COLORS+=":warning=${_BASHRC_COLORS[yellow]}"
	GCC_COLORS+=":note=${_BASHRC_COLORS[blue]}"
	GCC_COLORS+=":quote=${_BASHRC_COLORS[green]}"
	export GCC_COLORS

	# googletest colors
	export GTEST_COLOR=1

	# man colors
	export GROFF_NO_SGR=1
	export MANPAGER="less -R --use-color -Ddb -Duy -DSkw -DPkw"
fi

# Export locales for macOS
if [ "$_BASHRC_OSTYPE" = "macos" ]; then
	# Disable weird encoding of manpages
	export MANOPT="-E ascii"
fi

unset -v file
unset -v dir
