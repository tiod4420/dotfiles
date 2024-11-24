#!/usr/bin/env bash
#
# Global and environment variable settings

# Readline editing mode as vi
set -o vi

# Append history to the file, to avoid parallel shells erasing each other
shopt -s histappend 2> /dev/null

# History substitutions are not executed directly, but added to the line
shopt -s histverify 2> /dev/null

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
export HISTIGNORE='clear:exit:ls:ll:ls -l:la:ls -la:tree:bg:fg:cd:..:cd ..:popd'

# Quit here if we don't have colors
! _bashrc_has_colors && return

# ls colors
eval $(dircolors -b $(dirname ${BASH_SOURCE[0]})/dircolors.db)

# gcc colors
GCC_COLORS=""
GCC_COLORS+="locus=${_bashrc_colors[bold]};${_bashrc_colors[brwhite]}"
GCC_COLORS+=":error=${_bashrc_colors[red]}"
GCC_COLORS+=":warning=${_bashrc_colors[yellow]}"
GCC_COLORS+=":note=${_bashrc_colors[blue]}"
GCC_COLORS+=":quote=${_bashrc_colors[green]}"
export GCC_COLORS

# googletest colors
export GTEST_COLOR=1

# man colors
export GROFF_NO_SGR=1
export MANPAGER='less -R --use-color -Ddb -Duy -DSkw -DPkw'
