#!/usr/bin/env bash
#
# Functions settings

# Simple calculator
calc() {
	python -c "from math import *; print($*)"
}

# Search for files without NL at end of file
crlf() {
	local dir=${1:-.}
	find "$dir" -type f -exec grep -q "$(printf \\r)" {} \; -print
}

# Convert Epoch timestamp to date or reverse
epoch() {
	local mode=epoch

	# Parse parameters
	case "${1:-}" in
		-r | --revert) mode=revert && shift ;;
	esac

	case "$mode" in
		epoch) date ${1:+--date "$1"} +%s ;;
		revert) date ${1:+--date @"$1"} +%FT%T ;;
	esac
}

# Make a .tar.gz archive from a list of anything
mktar() {
	local name=$(basename "${1:-}")
	[ -n "$name" ] && tar czvf "$name.tar.gz" "$@"
}

# Search for files without NL at end of file
nonl() {
	local dir=${1:-.}
	find "$dir" -type f -not -exec sh -c '[ -z "$(tail -c1 $0)" ]' {} \; -print
}

# Open notes directory
notes() {
	local dir=${NOTES_DIR:-$HOME}
	local file=${1:-todo}
	local new_File

	if ! [ -f "$dir/$file" ]; then
		# Try to lowercase the name and add .md extension
		new_file=${file,,?}.md
		[ -f "$dir/$new_file" ] && file=$new_file
	fi

	vim "$dir/$file"
}

# Plot data with gnuplot
plot() {
	local mode=lines
	local range=1:2
	local terminal=dumb
	local -a args=()
	local file
	local style
	local yrange

	# Parse options
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-g | --gui)
				terminal="qt persist"
				shift
				;;
			-h | --histogram)
				mode=histogram
				shift
				;;
			-r | --range)
				if [ -z "${2:-}" ]; then
					echo "$FUNCNAME: option $1 requires an argument" >&2
					return 1
				fi
				range=$2
				shift 2
				;;
			-z | --zero)
				yrange=0
				shift
				;;
			--)
				shift
				break
				;;
			-*)
				echo "$FUNCNAME: invalid option -- ${1:-}" >&2
				return 1
				;;
			*)
				break
				;;
		esac
	done

	# STDIN if not specified
	file=${1:--}

	# Set gnuplot commands
	args=(
		-e "set terminal $terminal"
		-e "unset key"
		-e "set xtics scale 0"
		-e "set ytics scale 0"
		-e "set grid ytics"
		-e 'set format y "%.0f"'
		-e "set yrange [${yrange:-}:]"
	)

	# Plot graph
	case "$mode" in
		histogram)
			args+=(
				-e 'set format x "%Y\n%b"'
				-e "set xdata time"
				-e "set boxwidth 20*24*60*60 absolute"
				-e "set style fill solid noborder"
				-e 'set timefmt "%Y-%m-%d"'
			)
			style=boxes
			;;
		lines)
			style=linespoints
			;;
	esac

	gnuplot "${args[@]}" -e "plot '$file' using $range with $style"
}

# Hash a file line by line
shaline() {
	local file=${1:-}
	local nl

	! [ -f "$file" ] && return

	nl=$(wc -l "$file" | cut -d' ' -f1)

	# Compute SHA256 from start to i^th line
	for i in $(seq ${nl:-0}); do
		head -n $i "$file" | sha256sum | cut -d' ' -f1
	done
}

# Swap (or select) fields
swap() {
	local left=${1:--1}
	local right=${2:-0}

	# Normalize if negative value
	[ "$left" -lt 0 ] && left="NF + $left"
	[ "$right" -lt 0 ] && right="NF + $right"

	# 0-based index
	awk "{ print \$($left + 1),\$($right + 1) }"
}

# Display today's date in sort of ISO 8601 format
today() {
	local format="%F"

	case "${1:-}" in
		-f | --full) format="%FT%T" && shift ;;
		-i | --iso) format="%FT%T%:z" && shift ;;
	esac

	date ${1:+--date "$1"} +"$format"
}

# Download a X.509 certificate from an URL
x509_fetch() {
	local showcerts
	local host
	local servername

	# Parse options
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-a | --all)
				showcerts=all
				shift
				;;
			-s | --servername)
				if [ -z "${2:-}" ]; then
					echo "$FUNCNAME: option $1 requires an argument" >&2
					return 1
				fi
				servername=$2
				shift 2
				;;
			--)
				shift
				break
				;;
			-*)
				echo "$FUNCNAME: invalid option -- ${1:-}" >&2
				return 1
				;;
			*)
				break
				;;
		esac
	done

	host=$1

	# Add default port to 443 if not specified
	! echo "$host" | grep -qE ":[0-9]+$" && host+=":443"

	openssl s_client -connect "$host" \
		${showcerts:+-showcerts} ${servername:+-servername "$servername"} \
		< /dev/null \
		| sed -n "/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p"
}
