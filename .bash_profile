#!/usr/bin/env bash

# Bash startup files, according to the manual
# | Interactive | Login | File                            |
# | ----------- | ----- | ------------------------------- |
# | yes         | yes   | /etc/profile -> ~/.bash_profile |
# | no          | yes   | /etc/profile -> ~/.bash_profile |
# | yes         | no    | ~/.bashrc                       |
# | no          | no    | $BASH_ENV                       |

# That's how it should be done according to the manual
[ -f ~/.bashrc ] && source ~/.bashrc
