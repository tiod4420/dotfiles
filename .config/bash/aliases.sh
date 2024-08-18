#!/usr/bin/env bash

# Normalize open across Linux and OSX
! _bashrc_has_cmd open && alias open='xdg-open';

# Easier navigation
alias ..='cd ..'
alias ...='cd ../..'

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

# OpenSSL aliases
alias asn1parse='openssl asn1parse -i -dump'
alias base64='openssl base64'
alias csr='openssl req -text -noout'
alias x509='openssl x509 -text -noout'

# tarball aliases
alias lstar='tar tvf'
alias mktar='tar caf'
alias untar='tar xvf'

# Duplicates aliases
alias lsdupes='fdupes -r'
alias nodupes='(cat -n | sort -k 2 -u | sort -k 1 -n | cut -f 2-)'

# Python3 aliases
alias http='python3 -m http.server'
alias json-format='python3 -m json.tool'

# Hexdump of data (can be reversed with -r)
alias dump='xxd -g 1'
# Rank history commands by usage
alias histtop='history | sed -E "s/^ *[0-9]+ +//" | sort | uniq -c | sort -nr'
# Map list of arguments
alias map='xargs -n1'
# ROT13 data
alias rot13='tr "[:upper:][:lower:]" "N-ZA-Mn-za-m"'
