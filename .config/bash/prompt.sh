#!/usr/bin/env bash

_prompt_color()
{
	! _bashrc_has_colors && return
	echo "${2:-\[}\e[${_bashrc_colors[${1:-reset}]}m${3:-\]}"
}

# Configure __git_ps1
_bashrc_has_colors && GIT_PS1_SHOWCOLORHINTS=yes
GIT_PS1_SHOWSTASHSTATE=yes
GIT_PS1_SHOWDIRTYSTATE=yes

# Set PS1
PS1=""
PS1+=$(_prompt_color $([ "$USER" != "root" ] && echo cyan || echo red))
PS1+="\u"
PS1+=$(_prompt_color reset)
PS1+="@"
PS1+=$(_prompt_color $([ -z "$SSH_CLIENT" ] && echo magenta || echo yellow))
PS1+="\h"
PS1+=$(_prompt_color reset)
PS1+=" \w"
PS1+=$(_bashrc_has_cmd __git_ps1 && echo '$(__git_ps1 " -- %s")')
PS1+="\n$ "
PS1+=$(_prompt_color reset)

# Set PS2
PS2="> $(_prompt_color reset)"

# Set vi editing mode strings
if _bashrc_has_colors; then
	bind "set show-mode-in-prompt on"
	bind "set vi-ins-mode-string \"$(_prompt_color reset '\1' '\2')\""
	bind "set vi-cmd-mode-string \"$(_prompt_color red '\1' '\2')\""
fi

unset -f _prompt_color
