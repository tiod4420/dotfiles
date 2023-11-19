#!/usr/bin/env bash
#
# Prompt creation

if _has_colors; then
	export PS1="\[\e[31m\]\u@\h\[\e[0m\] \w\n\$ "
	# TODO: PS2, PS3, PS4
else
	export PS1="\u@\h \w\n\$ "
	# TODO: PS2, PS3, PS4
fi

#TEST=`bind -v | awk '/keymap/ {print $NF}'`
#if [ "$TEST" = 'vi-insert' ]; then
#    echo -ne "\033]12;Green\007"
#else
#    echo -ne "\033]12;Red\007"
#fi
#
#export PS1="\u@\h \$(kmtest.sh)> "
