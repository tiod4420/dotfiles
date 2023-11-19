#!/usr/bin/env bash
#
# Prompt creation

__prompt_git_details()
{
	local branch_name=""
	local flags=""

	# Check if the current directory is in a Git repository
	! git rev-parse --is-inside-work-tree &> /dev/null && return

	# Check if in .git/ directory
	if [ "false" = "$(git rev-parse --is-inside-git-dir)" ]; then
		# Check for uncommitted changes in the index
		! git diff --quiet --ignore-submodules --cached &&
			flags+="+"
		# Check for unstaged changes
		! git diff-files --quiet --ignore-submodules -- &&
			flags+="!"
		# Check for untracked files
		[ -n "$(git ls-files --others --exclude-standard)" ] &&
			flags+="?"
		# Check for stashed files
		git rev-parse --verify refs/stash &>/dev/null &&
			flags+="$"
	fi

	[ -n "$flags" ] && flags=" [$flags]"

	# Get the short symbolic ref
	branch_name=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
	[ -z "$branch_name" ] &&
		branch_name=$(git rev-parse --short HEAD 2> /dev/null)
	# Otherwise, just give up
	[ -z "$branch_name" ] &&
		branch_name=$(echo "(unknown)")
	branch_name=$(echo ${branch_name} | tr -d "\n")

	echo "-- ${1}${branch_name}${2}${flags}"
}

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
		user_style="[ \"root\" != \"$USER\" ] "
		user_style+="&& echo \"${yellow}\" || echo \"${red}\""

		# Set host color according to SSH or not (static)
		[ -z "$SSH_TTY" ] && host_style="$orange" || host_style="$green"

		# vi edition mode strings
		vi_ins_string="\1${white}\2"
		vi_cmd_string="\1${red}\2"

		# PS2: color will be set accordingly to vi mode
		PS2="> \[${reset}\]"
	else
		# vi edition mode strings
		vi_ins_string="$"
		vi_cmd_string="*"
	fi

	# PS1: user@host pwd (-- <branch> [flags])
	PS1=""
	PS1+="\[${reset}\]"
	PS1+="\[\$(${user_style})\]\u"
	PS1+="\[${white}\]@"
	PS1+="\[${host_style}\]\h"
	PS1+=" "
	PS1+="\[${white}\]\w"
	if [ 0 -ne "$PROMPT_GIT_STATUS" ]; then
		PS1+=" \$(command -v __prompt_git_details &> /dev/null &&"
		PS1+="__prompt_git_details \"${cyan}\" \"${blue}\")"
	fi
	[ "$TERM_COLORS" -ge 256 ] && PS1+="\n\$ \[${reset}\]" || PS1+="\n "

	# PS4: + FILE:LINENO: <cmd>
	PS4=""
	PS4+="\[${red}\]+"
	PS4+=" "
	PS4+="\[${green}\]\${BASH_SOURCE}"
	PS4+="\[${white}\]:"
	PS4+="\[${green}\]\${LINENO}"
	PS4+="\[${white}\] - "
	PS4+="\[${reset}\]"

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
	# Export PS4
	[ -n "$PS4" ] && export PS4
}

prompt
unset -f prompt
