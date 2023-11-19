#!/usr/bin/env bash
#
# Global alias mappings

## Easier navigation: .., ..., ...., ....., ~ and -
#alias ..="cd .."
#alias ...="cd ../.."
#
## Shortcuts
## TODO: cd or pushd?
#alias cdl="cd ~/Downloads"
#alias cdw="cd ~/Workspace"
#
#alias g="git"
#
## Detect which `ls` flavor is in use
#if ls --color > /dev/null 2>&1; then # GNU `ls`
#	colorflag="--color"
#	export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
#else # macOS `ls`
#	colorflag="-G"
#	export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
#fi
#
## Always use color output for `ls`
#alias ls="command ls ${colorflag}"
## TODO
#alias ll="ls -lhF ${colorflag}"
## List all files colorized in long format, excluding . and ..
#alias la="ls -lhFA ${colorflag}"
#
## Always enable colored `grep` output
## Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
#alias grep='grep --color=auto'
#alias fgrep='fgrep --color=auto'
#alias egrep='egrep --color=auto'
#
## Enable aliases to be sudo’ed
#alias sudo='sudo '
#
## IP addresses
##alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
##alias localip="ipconfig getifaddr en0"
##alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
#
## Show active network interfaces
##alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"
#
### Canonical hex dump; some systems have this symlinked
##command -v hd > /dev/null || alias hd="hexdump -C"
#
### Trim new lines and copy to clipboard
##alias c="tr -d '\n' | pbcopy"
##
### Recursively delete `.DS_Store` files
##alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
#
### URL-encode strings
##alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
#
### Merge PDF files, preserving hyperlinks
### Usage: `mergepdf input{1,2,3}.pdf`
##alias mergepdf='gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=_merged.pdf'
#
### Intuitive map function
### For example, to list all directories that contain a certain file:
### find . -name .gitattributes | map dirname
##alias map="xargs -n1"
#
## Reload the shell (i.e. invoke as a login shell)
#alias reload="exec ${SHELL} -l"
#
## Print each PATH entry on a separate line
#alias path='echo -e ${PATH//:/\\n}'
#
### Aliases
##alias grep="grep --color=auto"
##alias ls="ls --color=auto"
##alias ll="ls -lh"
##alias la="ll -a"
#
## TODO
### Enable tab completion for `g` by marking it as an alias for `git`
##if type _git &> /dev/null; then
##	complete -o default -o nospace -F _git g;
##fi;
#
## Use Git’s colored diff when available
##hash git &>/dev/null;
##if [ $? -eq 0 ]; then
##	diff() {
##		git diff --no-index --color-words "$@";
##	}
##fi;
#
## Normalize `open` across Linux, macOS, and Windows.
## This is needed to make the `o` function (see below) cross-platform.
#if [ ! $(uname -s) = 'Darwin' ]; then
#	if grep -q Microsoft /proc/version; then
#		# Ubuntu on Windows using the Linux subsystem
#		alias open='explorer.exe';
#	else
#		alias open='xdg-open';
#	fi
#fi
#
#
## `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
## the `.git` directory, listing directories first. The output gets piped into
## `less` with options to preserve color and line numbers, unless the output is
## small enough for one screen.
#function tre() {
#	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
#}
