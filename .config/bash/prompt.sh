#!/usr/bin/env bash
#
# Prompt settings

_prompt_color()
{
	local color
	local text

	# Get color and text
	[ -n "$1" ] && color=$1 && shift
	[ -n "$1" ] && text=$1 && shift

	if _bashrc_has_colors; then
		[ -n "$color" ] && echo -n "\[\e[${_BASHRC_COLORS[${color}]}m\]"
		[ -n "$text" ] && echo -n "$text"
		echo "\[\e[${_BASHRC_COLORS[reset]}m\]"
	else
		[ -n "$text" ] && echo "$text"
	fi
}

_prompt_git()
{
	_bashrc_has_cmd __git_ps1 && echo '$(__git_ps1)'
}

# Try to source git-prompt.sh
for file in "${_BASHRC_GIT_PROMPT[@]}"; do
	_bashrc_try_source "$file" && break
done

# Configure git prompt
_bashrc_has_colors && GIT_PS1_SHOWCOLORHINTS=yes

# Set PS1
_PROMPT_USER=$([ "$USER" != "root" ] && echo cyan || echo red)
_PROMPT_HOST=$([ -z "$SSH_CLIENT" ] && echo yellow || echo magenta)

PS1=$(_prompt_color $_PROMPT_USER '\u')
PS1+='@'
PS1+=$(_prompt_color $_PROMPT_HOST '\h')
PS1+=' \w'
PS1+=$(_prompt_git)
PS1+='\n\$ '
PS1+=$(_prompt_color)

# Set PS2
PS2+=$(_prompt_color)

# Set vi editing mode strings
if _bashrc_has_colors; then
	bind "set show-mode-in-prompt on"
	bind "set vi-ins-mode-string \1\e[${_BASHRC_COLORS[reset]}m\2"
	bind "set vi-cmd-mode-string \1\e[${_BASHRC_COLORS[red]}m\2"
fi

unset -v _PROMPT_HOST
unset -v _PROMPT_USER
unset -v file

unset -f _prompt_color
unset -f _prompt_git
