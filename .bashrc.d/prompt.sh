#!/usr/bin/env bash
#
# Prompt creation

# TODO
prompt()
{

#if _has_colors; then
#	export PS1="\[\e[31m\]\u@\h\[\e[0m\] \w\n\$ "
#else
#	export PS1="\u@\h \w\n\$ "
#fi

	#set show-mode-in-prompt on
	bind 'set show-mode-in-prompt on'
	bind "set vi-ins-mode-string \1\e[34;1m\2\$\1\e[0m\2"
	bind "set vi-cmd-mode-string \1\e[35;1m\2\$\1\e[0m\2"
	export PS1="\[\e[31m\]\u@\h\[\e[0m\] \w\n "
}

prompt
unset -f prompt
