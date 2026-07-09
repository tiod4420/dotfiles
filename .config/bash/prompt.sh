#!/usr/bin/env bash
#
# Prompt settings

_prompt_color() {
	local color=${1:-}
	local text=${2:-}
	local prefix
	local suffix

	# Set prefix and suffix if we have colors
	if _bashrc_has_colors; then
		prefix=${color:+"\[\e[${_BASHRC_COLORS[$color]}m\]"}
		suffix="\[\e[${_BASHRC_COLORS[reset]}m\]"
	fi

	echo "${prefix}${text}${suffix}"
}

# Try to source git-prompt.sh
for file in "${_BASHRC_GIT_PROMPT[@]}"; do
	_bashrc_try_source "$file" && break
done

# Set PS1
[ "$USER" != "root" ] && _PROMPT_USER=cyan || _PROMPT_USER=red
[ -z "$SSH_CLIENT" ] && _PROMPT_HOST=yellow || _PROMPT_HOST=magenta

PS1=$(_prompt_color $_PROMPT_USER '\u')
PS1+='@'
PS1+=$(_prompt_color $_PROMPT_HOST '\h')
PS1+=' \w'
PS1+=$(_bashrc_has_cmd __git_ps1 && echo '$(__git_ps1)')
PS1+='\n\$'
PS1+=$(_prompt_color)
PS1+=' '

# Set PS2
PS2+=$(_prompt_color)

if _bashrc_has_colors; then
	# Configure git prompt
	GIT_PS1_SHOWCOLORHINTS=yes

	# Set vi editing mode strings
	bind "set show-mode-in-prompt on"
	bind "set vi-cmd-mode-string \1\e[${_BASHRC_COLORS[red]}m\2"
	bind "set vi-ins-mode-string \1\e[${_BASHRC_COLORS[reset]}m\2"
fi

unset -v _PROMPT_HOST
unset -v _PROMPT_USER
unset -v file

unset -f _prompt_color
