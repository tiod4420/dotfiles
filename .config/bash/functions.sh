#!/usr/bin/env bash
#
# Functions settings

# Simple calculator
calc() {
	python -c "from math import *; print($*)"
}

# Hash a file line by line
fhash() {
	local file=$1
	local nl=$(wc -l "$file")

	# Compute SHA256 from start to i^th line
	for i in $(seq ${nl:-0}); do
		head -n $i "$file" | sha256sum
	done
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

# Plot data with gnuplot
plot() {
	local file=${1:--}
	local terminal=${2:-dumb}
	# Plot graph defaulting on terminal for output, and using STDIN if not file specified
	gnuplot -e "set terminal $terminal; plot '$file' using 0:1 with linespoints;"
}

# rg --passthru but with grep
cgrep() {
	local pattern=$1
	shift
	# Match pattern, or end of line, so only pattern is colored
	grep "\($pattern\)\|$" "$@"
}
