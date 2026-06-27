#!/usr/bin/env bash
#
# Alias settings

# Easier navigation
alias ..='cd ..'
alias ...='cd ../..'
alias gd='cd $(git rev-parse --show-toplevel || echo .)'

# Safe cp and mv
alias cp='cp -i'
alias mv='mv -i'

# ls aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ll -a'

# Colors aliases
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

# Find aliases
alias ff='find . -name'
alias fh='history | grep'
alias ft='grep -rIi --exclude-dir={.git,build,target}'


# PATH and MANPATH aliases
alias lsman='man --path | tr ":" "\n"'
alias lspath='echo $PATH | tr ":" "\n"'

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

# Count occurences of similar lines
alias count='(sort | uniq -c | sort -nr)'
# Hexdump of data (can be reversed with -r)
alias dump='xxd -g 1'
# Filter file to keep only last extension
alias fileext='sed -nE "s/^.*[^/]\.([^./]+)$/\1/p"'
# Git diff out of repository
alias gdiff='git diff --no-index'
# List history commands without prefix number
alias hist='history | sed -nE "s/^[[:space:]]*[0-9]+[[:space:]]+//p"'
# Spawn a HTTP server on current directory
alias http='python3 -m http.server'
# Map list of arguments
alias map='xargs -n1'
# Remove dupplicated lines while keeping order
alias nodupes='(cat -n | sort -k 2 -u | sort -k 1 -n | cut -f 2-)'
# ROT13 data
alias rot13='tr "[:upper:][:lower:]" "N-ZA-Mn-za-m"'
# List unique lines only
alias soun='sort | uniq'
# Search for SyncThing conflicts
alias syncoops='[ -d "$SYNCTHING_DIR" ] && find $SYNCTHING_DIR -name "*.sync-conflict.*"'
# Search for TODOs
alias todo='ft "\<TODO\>"'
# Trim line from front and back spaces
alias trim='sed -nE "s/^[[:space:]]*(.*[^[:space:]])[[:space:]]*$/\1/p"'

# Normalize open across Linux and OSX
! _bashrc_has_cmd open && alias open='xdg-open';

# clear doesn't clear tmux scrollback buffer on macOS
[ "$_BASHRC_OSTYPE" = "macos" ] && alias clear='clear && tmux clear-history'
