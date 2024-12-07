#!/usr/bin/env bash
#
# Prompt settings

_prompt_color()
{
	_bashrc_has_colors && echo "\e[${_bashrc_colors[$1]}m"
}

# Try to source git-prompt.sh
for file in "${_bashrc_git_prompt[@]}"; do
	_bashrc_try_source $file && break
done

# Configure git prompt
_bashrc_has_colors && GIT_PS1_SHOWCOLORHINTS=yes

# Set PS1
PS1=""
PS1+="\[$(_prompt_color $([ "$USER" != "root" ] && echo cyan || echo red))\]"
PS1+='\u'
PS1+="\[$(_prompt_color reset)\]"
PS1+='@'
PS1+="\[$(_prompt_color $([ -z "$SSH_CLIENT" ] && echo yellow || echo magenta))\]"
PS1+='\h'
PS1+="\[$(_prompt_color reset)\]"
PS1+=' \w'
PS1+=$(_bashrc_has_cmd __git_ps1 && echo '$(__git_ps1)')
PS1+='\n\$ '
PS1+="\[$(_prompt_color reset)\]"

# Set PS2
PS2+="\[$(_prompt_color reset)\]"

# Set vi editing mode strings
bind "set show-mode-in-prompt on"
bind "set vi-ins-mode-string \1$(_prompt_color reset)\2"
bind "set vi-cmd-mode-string \1$(_prompt_color red)\2"

unset -v file

unset -f _prompt_color
