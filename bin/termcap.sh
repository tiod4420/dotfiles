#!/usr/bin/env bash

infocmp -1 | tr -d '\0\t,' | cut -d '=' -f 1 | grep -v "$TERM" | sort | column -c 80
