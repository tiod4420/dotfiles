#!/usr/bin/env bash
#
# Global environment variables settings

# Set Homebrew bin and man to path
if [ 'osx' = "$(_os_name)" ] && _has_brew; then
	# GNU coreutils
	PATH="$(brew --prefix coreutils)/libexec/gnubin:${PATH}"
	MANPATH="$(brew --prefix coreutils)/libexec/gnuman:${MANPATH}"
	# GNU grep
	PATH="$(brew --prefix grep)/libexec/gnubin:${PATH}"
	MANPATH="$(brew --prefix grep)/libexec/gnuman:${MANPATH}"
fi

# Set language preferences
export LANG='en_US.UTF-8';
# Set locale preferences
export LC_ALL='en_US.UTF-8';

# Make vim the default editor.
export EDITOR='vim'
# Make less the default pager
export PAGER='less'
# Make less the default man pager
export MANPAGER='less';

# Increase Bash history size
export HISTSIZE='32768';
# Increase Bash history file size
export HISTFILESIZE=${HISTSIZE};
# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL='ignoreboth';

if _has_colors; then
	case $(_ls_type) in
		'gnuls')
			# TODO: customize
			export LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'
			;;
		'freebsd')
			export CLICOLOR=1

			# Set ls colors
			LSCOLORS=""
			LSCOLORS+="ex" # Directory
			LSCOLORS+="gx" # Symbolic link
			LSCOLORS+="fx" # Socket
			LSCOLORS+="dx" # Pipe
			LSCOLORS+="cx" # Executable
			LSCOLORS+="xd" # Block special
			LSCOLORS+="xc" # Character special
			LSCOLORS+="xb" # Executable (suid)
			LSCOLORS+="xe" # Executable (guid)
			LSCOLORS+="xg" # Directory o+w (sticky bit)
			LSCOLORS+="xf" # Directory o+w (no sticky bit)

			export LSCOLORS
			;;
	esac

	# Set GCC messages colors
	GCC_COLORS=''
	# TODO: customize
	GCC_COLORS+='error=1;31:'
	GCC_COLORS+='warning=1;35:'
	GCC_COLORS+='note=1;36:'
	GCC_COLORS+='caret=1;32:'
	GCC_COLORS+='locus=1:'
	GCC_COLORS+='quote=1'

	export GCC_COLORS

	# Set less colors
	# TODO: customize colors, adjust because of printenv bug
	#export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
	#export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
	#export LESS_TERMCAP_me=$(tput sgr0)
	#export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
	#export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
	#export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
	#export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
	#export LESS_TERMCAP_mr=$(tput rev)
	#export LESS_TERMCAP_mh=$(tput dim)
	#export LESS_TERMCAP_ZN=$(tput ssubm)
	#export LESS_TERMCAP_ZV=$(tput rsubm)
	#export LESS_TERMCAP_ZO=$(tput ssupm)
	#export LESS_TERMCAP_ZW=$(tput rsupm)
	#export GROFF_NO_SGR=1         # For Konsole and Gnome-terminal
	## Highlight section titles in manual pages.

	# Set GTest colors
	export GTEST_COLOR=1
fi
