#!/usr/bin/env bash
#
# Functions settings

# Simple calculator
calc() {
	python -c "from math import *; print($*)"
}

# Count occurences of similar lines
count() {
	sort "$@" | uniq -c | sort -nr
}

# Drop first or last n lines
drop() {
	local OPTIND
	local OPTARG
	local opt
	local n

	# Parse options
	while getopts ":n:" opt; do
		case "$opt" in
			n) n=$OPTARG ;;
			:) echo "$FUNCNAME: option requires an argument -- $OPTARG" && return 1 ;;
			?) echo "$FUNCNAME: illegal option -- $OPTARG" && return 1 ;;
		esac
	done

	shift $((OPTIND - 1))

	# Same default as head or tail
	[ -z "${n:-}" ] && n=10

	# Drop lines
	case "$n" in
		-*) head -n $n -- "$@" ;;
		*) tail -n +$((n + 1)) -- "$@" ;;
	esac
}

# List functions names or specific function implementatioe
functions() {
	if [ "$#" -eq 0 ]; then
		declare -F | sed -e 's/^declare -f //' -e '/^_/d'
	else
		declare -f "$1"
	fi
}

# Convert Epoch timestamp to date or reverse
epoch() {
	local mode=epoch

	# Parse options
	case "${1:-}" in
		-r | --revert) mode=revert && shift ;;
	esac

	# Get epoch
	case "$mode" in
		epoch) date ${1:+--date "${1:-}"} +%s ;;
		revert) date ${1:+--date @"${1:-}"} +%FT%T ;;
	esac
}

# Get file name or extension
filename() {
	local mode=name
	local name
	local ext

	# Parse options
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-e | --ext) mode=ext && shift ;;
			--) shift && break ;;
			-*) echo "$FUNCNAME: illegal option -- ${1:-}" >&2 && return 1 ;;
			*) break ;;
		esac
	done

	if [ -z "$1" ]; then
		echo "$FUNCNAME: invalid usage" >&2
		return 1
	fi

	# Get filename (without initial . if hidden file)
	name=$(basename -- "$1")

	# Normalize hidden files and get extension
	ext=$(echo "$name" | sed -n -e 's/^\.//' -e 's/.*\(\.[^.]*\)$/\1/p')

	case "$mode" in
		name) basename "$name" "$ext" ;;
		ext) [ -n "$ext" ] && echo "$ext" ;;
	esac
}

# Convert or revert to hex
hex() {
	local mode=hex

	# Parse options
	case "${1:-}" in
		-r | --revert) mode=revert && shift ;;
	esac

	# Get hex value
	case "$mode" in
		hex) xxd -g1 "$@" ;;
		revert) xxd -r "$@" ;;
	esac
}

# Make a directory and cd into it
mkcd() {
	[ -n "${1:-}" ] && mkdir -p -- "$1" && cd "$1"
}

# Make a .tar.gz archive from a list of anything
mktar() {
	local name=$(basename "${1:-}")
	[ -n "$name" ] && tar czvf "$name.tar.gz" "$@"
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

# Display today's date in sort of ISO 8601 format
now() {
	local format="%F"

	# Parse options
	case "${1:-}" in
		-f | --full) format="%FT%T" && shift ;;
		-i | --iso) format="%FT%T%:z" && shift ;;
	esac

	# Display date
	date ${1:+--date "$1"} +"$format"
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
			-g | --gui) terminal="qt persist" && shift ;;
			-h | --histogram) mode=histogram && shift ;;
			-r | --range)
				if [ -z "${2:-}" ]; then
					echo "$FUNCNAME: option requires an argument -- ${1:-}" >&2
					return 1
				fi
				range=$2
				shift 2
				;;
			-z | --zero) yrange=0 && shift ;;
			--) shift && break ;;
			-*) echo "$FUNCNAME: illegal option -- ${1:-}" >&2 && return 1 ;;
			*) break ;;
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

# Repeat a string n times
repeat() {
	local n

	if [ "$#" -lt 2 ]; then
		echo "$FUNCNAME: invalid usage" >&2
		return 1
	fi

	n=$1 && shift

	for i in $(seq $n); do
		printf "%s" "$@"
	done

	printf "\n"
}

# Search diverse type of files
search() {
	local cmd
	local dir
	local reverse

	# Get parameters
	if [ -z "${1:-}" ]; then
		echo "$FUNCNAME: missing command" >&2
		return 1
	fi

	cmd=${1:-} && shift
	dir=${1:-.} && shift

	case "$cmd" in
		crlf)
			# Files without NL at end of file
			find "$dir" "$@" -type f -exec grep -q "$(printf \\r)" {} \; -print
			;;
		empty)
			# Empty files or directories
			find "$dir" "$@" -empty
			;;
		largest | smallest)
			# Largest or smallest files
			[ "$cmd" = "largest" ] && reverse=true
			find "$dir" "$@" -printf "%s\t%p\n" | sort -n ${reverse:+-r}
			;;
		latest | oldest)
			# Most or less recently modified files
			[ "$cmd" = "latest" ] && reverse=true
			find "$dir" "$@" -printf "%TFT%.8TT %p\n" | sort ${reverse:+-r}
			;;
		nonl)
			# Files without NL at end of file
			find "$dir" "$@" -type f -not -exec sh -c '[ -z "$(tail -c1 "$0")" ]' {} \; -print
			;;
		today)
			# Files modified today
			find "$dir" "$@" -daystart -mtime -1
			;;
		ws)
			# Files with trailing whitespaces
			find "$dir" "$@" -type f -exec grep -q "[[:space:]]$" {} \; -print
			;;
		*)
			echo "$FUNCNAME: illegal command -- $cmd" >&2
			return 1
			;;
	esac
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

# Join strings with delimiter
strjoin() {
	local IFS="$1"
	shift
	echo "$*"
}

# Transpose lines into columns
transpose() {
	local OPTIND
	local OPTARG
	local opt
	local d
	local -a args=()

	# Parse options
	while getopts ":d:" opt; do
		case "$opt" in
			d) d=$OPTARG ;;
			:) echo "$FUNCNAME: option requires an argument -- $OPTARG" && return 1 ;;
			?) echo "$FUNCNAME: illegal option -- $OPTARG" && return 1 ;;
		esac
	done

	shift $((OPTIND - 1))

	# Set input and output field separators
	args+=(${d:+-v FS="'$d'"} ${d:+-v OFS="'$d'"})

	# Transpose lines to columns
	awk "${args[@]}" '
		{
			if (NF > cols) {
				cols = NF
			}

			for (i = 1; i <= NF; ++i) {
				data[i, NR] = $i
			}
		}
		END {
			for (i = 1; i <= cols; ++i) {
				for (j = 1; j <= NR; ++j) {
					printf "%s%s", data[i, j], (j == NR ? ORS : OFS)
				}
			}
		}
	' "$@"
}

# Download a X.509 certificate from an URL
x509_fetch() {
	local showcerts
	local host
	local servername

	# Parse options
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-a | --all) showcerts=all && shift ;;
			-s | --servername)
				if [ -z "${2:-}" ]; then
					echo "$FUNCNAME: option requires an argument -- ${1:-}" >&2
					return 1
				fi
				servername=$2
				shift 2
				;;
			--) shift && break ;;
			-*) echo "$FUNCNAME: illegal option -- ${1:-}" >&2 && return 1 ;;
			*) break ;;
		esac
	done

	host=$1

	# Add default port to 443 if not specified
	! echo "$host" | grep -qE ":[0-9]+$" && host+=":443"

	# Get certificates
	openssl s_client -connect "$host" \
		${showcerts:+-showcerts} ${servername:+-servername "$servername"} \
		< /dev/null \
		| sed -n "/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p"
}

# Select fields in lines
xcut() {
	local OPTIND
	local OPTARG
	local opt
	local d
	local f
	local -a args=()

	# Parse options
	while getopts ":d:f:" opt; do
		case "$opt" in
			d) d=$OPTARG ;;
			f) f=$OPTARG ;;
			:) echo "$FUNCNAME: option requires an argument -- $OPTARG" && return 1 ;;
			?) echo "$FUNCNAME: illegal option -- $OPTARG" && return 1 ;;
		esac
	done

	shift $((OPTIND - 1))

	# Set input and output field separators
	args+=(-v FUNCNAME="$FUNCNAME")
	args+=(-v f="${f:--1,1}")
	args+=(${d:+-v FS="$d"} ${d:+-v OFS="$d"})

	awk "${args[@]}" '
		BEGIN {
			len = 0
			split(f, fields, ",")

			for (i = 1; i <= length(fields); ++i) {
				# index 0 is not valid
				if (fields[i] == 0) {
					printf "%s: fields are numbered from 1\n", FUNCNAME > "/dev/stderr"
					exit 1
				}

				# Convert range into actual indices
				if (fields[i] ~ /^[0-9]+-[0-9]$/) {
					split(fields[i], range, "-")

					if (range[1] > range[2]) {
						printf "%s: invalid range -- %s\n", FUNCNAME, fields[i] > "/dev/stderr"
						exit 1
					}

					for (j = range[1]; j <= range[2]; ++j) {
						indices[++len] = j
					}

					continue
				}

				# Normal case
				indices[++len] = fields[i]
			}
		}
		{
			for (i = 1; i <= length(indices); ++i) {
				idx = (indices[i] >= 0) ? indices[i] : NF + indices[i] + 1
				sep = (i == length(indices)) ? ORS : OFS
				printf "%s%s", $(idx), sep
			}
		}
	' "$@"
}
