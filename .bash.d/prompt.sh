#!/usr/bin/env bash
#
# Prompt creation

if [ 0 -ne "$PROMPT_GIT_STATUS" ]; then
__prompt_git_details()
{
	local branch_name=""

	# Check if the current directory is in a Git repository
	! git rev-parse --is-inside-work-tree &> /dev/null && return

	# Get the short symbolic ref
	branch_name=$(git rev-parse --abbrev-ref HEAD 2> /dev/null | tr -d "\n")
	# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
	if [ -z "$branch_name" ]; then
		branch_name=$(git rev-parse --short HEAD 2> /dev/null | tr -d "\n")
		# Otherwise, just give up
		[ -z "$branch_name" ] && branch_name="(unknown)"
	fi

	echo "-- ${1}${branch_name}"
}
fi

prompt()
{
	local reset=""
	local red=""
	local green=""
	local yellow=""
	local blue=""
	local purple=""
	local cyan=""
	local white=""
	local orange=""
	local user_style=""
	local host_style=""
	local vi_ins_string=""
	local vi_cmd_string=""

	if [ "$TERM_COLORS" -ge 256 ]; then
		reset="\e[0m"
		red="\e[00;38;5;1m"
		green="\e[00;38;5;2m"
		yellow="\e[00;38;5;3m"
		blue="\e[00;38;5;4m"
		purple="\e[00;38;5;5m"
		cyan="\e[00;38;5;6m"
		white="\e[00;38;5;15m"
		orange="\e[00;38;5;166m"

		# Set user color according to root or not (dynamic)
		user_style="[ \"root\" != \"$USER\" ] && echo \"${yellow}\" || echo \"${red}\""

		# Set host color according to SSH or not (static)
		[ -z "$SSH_TTY" ] && host_style="$orange" || host_style="$green"
	fi

	# PS1: user@host pwd (-- <branch> [flags])
	PS1=""
	PS1+="\[${reset}\]"
	PS1+="\[\$(${user_style})\]\u"
	PS1+="\[${white}\]@"
	PS1+="\[${host_style}\]\h"
	PS1+=" "
	PS1+="\[${white}\]\w"
	command -v __prompt_git_details &> /dev/null && PS1+=" \$(__prompt_git_details \"${blue}\")"

	if [ "$TERM_COLORS" -ge 256 ]; then
		# vi edition mode strings
		vi_ins_string="\1${white}\2"
		vi_cmd_string="\1${red}\2"

		PS1+="\n\$ \[${reset}\]"
		# PS2: color will be set accordingly to vi mode
		PS2="> \[${reset}\]"
	else
		# vi edition mode strings
		vi_ins_string="$"
		vi_cmd_string="*"

		PS1+="\n "
	fi

	# Set vi editing mode string
	bind "set show-mode-in-prompt on"
	# Set string for vi insert mode
	bind "set vi-ins-mode-string \"${vi_ins_string}\""
	# Set string for vi command mode
	bind "set vi-cmd-mode-string \"${vi_cmd_string}\""

	# Export PS1
	[ -n "$PS1" ] && export PS1
	# Export PS2
	[ -n "$PS2" ] && export PS2
}

prompt
unset -f prompt
