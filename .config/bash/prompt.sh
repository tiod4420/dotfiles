#!/usr/bin/env bash
#
# Prompt creation

prompt()
{
	local vi_ins_string
	local vi_cmd_string

	# Setup PS1 and PS@, depending if there is colors and __git_ps1
	if [ "$TERM_COLORS" -lt 256 ]; then
		PS1="\u@\h \w\n "
		PS2=" "

		vi_ins_string="$"
		vi_cmd_string="*"
	else
		local ps1_prefix=$(build_ps1_prefix)
		local ps1_suffix=$(build_ps1_suffix)

		if check_has_cmd __git_ps1; then
			local gitformat=" -- %s"
			GIT_PS1_SHOWCOLORHINTS=1
			PROMPT_COMMAND="__git_ps1 '${ps1_prefix}' '${ps1_suffix}' '${gitformat}'"
		else
			PS1="${ps1_prefix}${ps1_suffix}"
		fi

		PS2=$(build_ps2)

		vi_ins_string="\1$(get_color white)\2"
		vi_cmd_string="\1$(get_color red)\2"
	fi

	# Set vi editing mode string
	bind "set show-mode-in-prompt on"
	bind "set vi-ins-mode-string \"${vi_ins_string}\""
	bind "set vi-cmd-mode-string \"${vi_cmd_string}\""
}

build_ps1_prefix()
{
	local user_style
	local host_style

	# Check if user is root
	is_normal_user && user_style=white || user_style=red
	# Check if host is local
	is_local_host && host_style=cyan || host_style=yellow

	get_color -m ps1 -d ${user_style} "\u"
	get_color -m ps1 reset "@"
	get_color -m ps1 ${host_style} "\h"
	get_color -m ps1 reset " \w"
}

build_ps1_suffix()
{
	echo -n "\n$ "
	get_color -m ps1 reset
}

build_ps2()
{
	echo -n "> "
	get_color -m ps1 reset
}

prompt
unset -f prompt
unset -f build_ps1_prefix build_ps1_suffix build_ps2
