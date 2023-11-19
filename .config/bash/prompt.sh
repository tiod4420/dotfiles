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
		local ps1_prefix="$(build_ps1_prefix)"
		local ps1_suffix="$(build_ps1_suffix)"

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

	# Set user depending if root or not
	[ "root" != "${USER}" ] && user_style="yellow" || user_style="red"
	# Set host color according to SSH or not (static)
	[ -z "$SSH_TTY" ] && host_style="color16" || host_style="green"

	set_color ${user_style}
	echo -n "\u"
	set_color white
	echo -n "@"
	set_color ${host_style}
	echo -n "\h"
	set_color reset
	echo -n " "
	set_color white
	echo -n "\w"
	set_color reset
}

build_ps1_suffix()
{
	echo -n "\n$ "
	set_color reset
}

build_ps2()
{
	echo -n "> "
	set_color reset
}

set_color()
{
	echo -n "\[$(get_color "$@")\]"
}

prompt
unset -f prompt
unset -f build_ps1_prefix build_ps1_suffix build_ps2
unset -f set_color
