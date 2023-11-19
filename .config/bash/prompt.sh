#!/usr/bin/env bash
#
# Prompt creation

prompt()
{
	local vi_ins_string
	local vi_cmd_string

	if [ "$TERM_COLORS" -ge 256 ]; then
		PS1=$(build_ps1)
		PS2=$(build_ps2)

		vi_ins_string="\1$(get_color white)\2"
		vi_cmd_string="\1$(get_color red)\2"
	else
		PS1="\u@\h \w \$(__prompt_git_details)\n "
		PS2=" "

		vi_ins_string="$"
		vi_cmd_string="*"
	fi

	# Export prompts
	export PS1
	export PS2

	# Set vi editing mode string
	bind "set show-mode-in-prompt on"
	bind "set vi-ins-mode-string \"${vi_ins_string}\""
	bind "set vi-cmd-mode-string \"${vi_cmd_string}\""
}

build_ps1()
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
	echo -n " "
	echo -n "\$(__prompt_git_details blue)"
	echo -n "\n"
	echo -n "$ "
	set_color reset
}

build_ps2()
{
	echo -n "> "
	set_color reset
}

set_color()
{
	local COLOR=$(get_color "$@")
	echo -n "\[${COLOR}\]"
}

__prompt_git_details()
{
	local color=$1
	# TODO:  display something only if we did not deactivated git branches display
	# TODO color
	echo "${color:-$(date)}"
}

prompt
unset -f prompt build_ps1 build_ps2 set_color
