#!/usr/bin/env bash
#
# Functions settings

# Simple calculator
calc() {
	python -c "from math import *; print($*)"
}

# Search for files without NL at end of file
crlf() {
	find "${1:-.}" -type f -exec grep -q "$(printf \\r)" {} \; -print
}

# Convert Epoch timestamp to date or reverse
epoch() {
	local mode=epoch

	# Parse parameters
	case "$1" in
		-r|--revert) mode=revert && shift ;;
	esac

	case "$mode" in
		epoch) date --date "${1:-now}" +%s ;;
		revert) date --date "@${1:-0}" +%FT%T ;;
	esac
}

# Make a .tar.gz archive from a list of anything
mktar() {
	local file=$(basename "$1")
	tar czvf $file.tar.gz "$@"
}

# Search for files without NL at end of file
nonl() {
	find "${1:-.}" -type f -not -exec sh -c '[ -z "$(tail -c1 $0)" ]' {} \; -print
}

# Open notes directory
notes() {
	local dir=${NOTES_DIR:-$HOME}
	local file=${1:-todo}

	if [ ! -f "$dir/$file" ]; then
		# Try to lowercase the name and add .md extension
		local new_file=${file,,?}.md
		[ -f "$dir/$new_file" ] && file=$new_file
	fi

	vim "$dir/$file"
}

# Display date in sort of ISO 8601 format
now() {
	date --date "${1:-now}" +%FT%T
}

# Plot data with gnuplot
plot() {
	local file=${1:--}
	local terminal=${2:-dumb}
	# Plot graph defaulting on terminal for output, and using STDIN if not file specified
	gnuplot -e "set terminal $terminal; plot '$file' using 0:1 with linespoints;"
}

# Hash a file line by line
shaline() {
	local file=$1
	local nl=$(wc -l < "$file")

	# Compute SHA256 from start to i^th line
	for i in $(seq ${nl:-0}); do
		head -n $i "$file" | sha256sum | cut -d' ' -f1
	done
}
