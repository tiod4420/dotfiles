#!/usr/bin/env bash

modes=(38 48)
colors=($(seq 0 255))

reset="\e[0m"

for mode in ${modes[@]} ; do
	for i in ${colors[@]} ; do
		name="^[${mode};5;${i}m"
		color="\e[${mode};5;${i}m"

		if [ 0 -ne ${i} ]; then
			[ 0 -eq $((${i} % 8)) ] && printf "|\n"
		fi

		printf "|"
		printf "${color}%-12s${reset}" "$name"
	done

	printf "|\n"
done

exit 0
