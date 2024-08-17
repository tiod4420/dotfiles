#!/usr/bin/env bash

base16_colors=(
	base00:Black
	base08:Red
	base0B:Green
	base0A:Yellow
	base0D:Blue
	base0E:Magenta
	base0C:Cyan
	base05:White
	base03:Bright_Black
	base08:Bright_Red
	base0B:Bright_Green
	base0A:Bright_Yellow
	base0D:Bright_Blue
	base0E:Bright_Magenta
	base0C:Bright_Cyan
	base07:Bright_White
	base09:
	base0F:
	base01:
	base02:
	base04:
	base06:
)

reset="\e[0m"

for i in ${!base16_colors[@]}; do
	base16_name=${base16_colors[${i}]%%:*}
	ansi_name=${base16_colors[${i}]##*:}

	fg_color="\e[38;5;${i}m"
	bg_color="\e[48;5;${i}m"

	printf "${fg_color}color%02d %s %-15s${reset}" "$i" "$base16_name" "$ansi_name"
	printf "|${bg_color}%-30s${reset}|"
	printf "\n"
done

exit 0
