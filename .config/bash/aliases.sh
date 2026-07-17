#!/usr/bin/env bash
#
# Alias settings

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias groot='cd $(git rev-parse --show-toplevel 2> /dev/null || pwd)'

# cp and mv aliases
alias cp='cp -i'
alias mv='mv -i'

# ls aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ll -A'

# find aliases
alias ff='find . -name'
alias fh='history | grep'
alias ft='grep -rIi --exclude-dir={.git,build,target}'

# gdb aliases
alias gef='gdb -ex start-gef'
alias peda='gdb -ex start-peda'
alias pwndbg='gdb -ex start-pwndbg'

# openssl aliases
alias asn1parse='openssl asn1parse -i -dump'
alias base64='openssl base64'
alias csr='openssl req -text -noout'
alias x509='openssl x509 -text -noout'

# tar aliases
alias lstar='tar tvf'
alias untar='tar xvf'

# tr aliases
alias gu='tr "[:upper:]" "[:lower:]"'
alias gU='tr "[:lower:]" "[:upper:]"'
alias g~='tr "[:upper:][:lower:]" "[:lower:][:upper:]"'
alias rot13='tr "A-Za-z" "N-ZA-Mn-za-m"'
alias trim='sed "s/^[[:space:]]*//; s/[[:space:]]*$//"'

# Colors aliases
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

# PATH and MANPATH aliases
alias lsman='man --path | tr ":" "\n"'
alias lspath='echo $PATH | tr ":" "\n"'

# List aliases
alias aliases='alias | sed "s/^alias[[:space:]]*\([^[:space:]]*\)='\''\(.*\)'\''$/\1 = \2/" | sort'
# Remove duplicates while preserving order
alias dedup='awk "!seen[\$0]++"'
# Flip line order
alias flip='tac'
# Git diff out of repository
alias gdiff='git diff --no-index'
# List history commands without prefix number
alias hist='history | sed "s/^[[:space:]]*[0-9]*[[:space:]]*//"'
# Spawn a HTTP server on current directory
alias http='python3 -m http.server'
# Map list of arguments
alias map='xargs -n1'
# Make a QR code
alias qr='qrencode -t ANSIUTF8'
# Search for SyncThing conflicts
alias syncoops='[ -d "$SYNCTHING_DIR" ] && find $SYNCTHING_DIR -name "*.sync-conflict*"'
# Search for TODOs
alias todo='ft "\<TODO\>"'

# Clipboard aliases
if _bashrc_has_cmd pbcopy; then
	alias cbcopy='pbcopy'
	alias cbpaste='pbpaste'
elif _bashrc_has_cmd wl-copy; then
	alias cbcopy='wl-copy --type "text/plain;charset=utf-8"'
	alias cbpaste='wl-paste'
elif _bashrc_has_cmd xclip; then
	alias cbcopy='xclip -selection clipboard -i'
	alias cbpaste='xclip -selection clipboard -o'
fi

# Normalize open across Linux and macOS
if ! _bashrc_has_cmd open; then
	alias open='xdg-open'
fi

# clear doesn't clear tmux scrollback buffer on macOS
if [ "$_BASHRC_OSTYPE" = "macos" ]; then
	alias clear='clear && tmux clear-history'
fi
