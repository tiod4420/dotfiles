#!/usr/bin/env bash
#
# Quick calculation with Python one-liner

local eval=$(printf "%s" "$@")
python -c "from math import *; print(${eval})"
