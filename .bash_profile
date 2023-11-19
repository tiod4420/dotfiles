#!/usr/bin/env bash
#
# Bash configuration for login shells

bashrc="${HOME}/.bashrc"
[ -f "${bashrc}" ] && [ -r "${bashrc}" ] && source ${bashrc}
unset bashrc
