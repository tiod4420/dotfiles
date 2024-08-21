#!/usr/bin/env bash

# Normalize open across Linux and OSX
! _bashrc_has_cmd open && alias open='xdg-open';

# Easier navigation
alias ..='cd ..'
alias ...='cd ../..'
alias gd='cd $(git root || echo .)'

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

# Search aliases
alias ff='find . -name'
alias ft='grep -RIi --exclude-dir={.git,build}'
alias todo='ft TODO'

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

# python3 aliases
alias http='python3 -m http.server'
alias json-format='python3 -m json.tool'

# tar aliases
alias lstar='tar tvf'
alias mktar='tar caf'
alias untar='tar xvf'

# Count occurences of similar lines
alias count='sort | uniq -c | sort -nr'
# Hexdump of data (can be reversed with -r)
alias dump='xxd -g 1'
# Filter file to keep only last extension
alias fileext='sed -nE "s/^.*[^/]\.([^./]+)$/\1/p"'
# List history commands without prefix number
alias hist='history | sed -nE "s/^[[:space:]]*[0-9]+[[:space:]]+//p"'
# Map list of arguments
alias map='xargs -n1'
# Remove dupplicated lines while keeping order
alias nodupes='(cat -n | sort -k 2 -u | sort -k 1 -n | cut -f 2-)'
# ROT13 data
alias rot13='tr "[:upper:][:lower:]" "N-ZA-Mn-za-m"'
