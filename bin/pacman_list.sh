#!/usr/bin/env bash

# Generate cargo.txt
cargo install --list > cargo.txt

# Generate gnome.txt
pacman -Qge | grep '^gnome ' | cut -d' ' -f2 > gnome.txt

# Generate gnome-extra.txt
pacman -Qge | grep '^gnome-extra ' | cut -d' ' -f2 > gnome-extra.txt

# Generate texlive-most.txt
pacman -Qge | grep '^texlive ' | cut -d' ' -f2 > texlive-most.txt

# Generate paru.txt
pacman -Qqm > paru.txt

# Generate pacman.txt
pacman -Qqe | grep -v -x -f gnome.txt -f gnome-extra.txt -f texlive-most.txt -f paru.txt > pacman.txt

# Generate all.txt
pacman -Qq > all.txt
