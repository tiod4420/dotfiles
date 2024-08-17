#!/usr/bin/env bash

if [ 1 -ne "$#" ]; then
	echo "$0: missing destinaty directory" >&2
	exit 1
fi

# Backup directories and delete extra files
rsync -aPh --delete ${HOME}/Documents "$1"
rsync -aPh --delete ${HOME}/Dropbox   "$1"
rsync -aPh --delete ${HOME}/Ebooks    "$1"
rsync -aPh --delete ${HOME}/Music     "$1"
rsync -aPh --delete ${HOME}/Pictures  "$1"
rsync -aPh --delete ${HOME}/Workspace "$1"
