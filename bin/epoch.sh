#!/usr/bin/env bash
#
# Handle epoch time

local OPTARG
local OPTIND
local opts
local mode="epoch"
local version
local date
local args
local fmt

# Parse arguments
while getopts ":r" opts; do
	case "$opts" in
		r) mode="date";;
		\?) (1>&2 echo "${FUNCNAME}: invalid parameter: -${OPTARG}") && return 1;;
	esac
done

shift $((OPTIND - 1))
date="$1"

# Get date flavour (GNU or BSD)
if date --version &> /dev/null; then
	version=gnu
else
	version=bsd
fi

case "${version}_${mode}" in
	gnu_epoch) date -u    ${date:+--date="${date}"}     +"%s";;
	bsd_epoch) date -u -j ${date:+-f "%F %T" "${date}"} +"%s";;
	gnu_date)  date -u    ${date:+--date="@${date}"}    +"%F %T";;
	bsd_date)  date -u -j ${date:+-r "${date}"}         +"%F %T";;
esac
