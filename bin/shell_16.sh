#!/usr/bin/env bash

bg_colors=(49 $(seq 40 47) $(seq 100 107))
fg_colors=(39 $(seq 30 37) $(seq 90 97))
attrs=(0 1 2 4 5 7)

reset="\e[0m"

for bg_color in ${bg_colors[@]} ; do
	for fg_color in ${fg_colors[@]}; do
		for attr in ${attrs[@]}; do
			name="^[${attr};${bg_color};${fg_color}m"
			color="\e[${attr};${bg_color};${fg_color}m"

			printf "|"
			printf "${color}%-12s${reset}" "${name}"
		done

		printf "|\n"
	done
done

exit 0
