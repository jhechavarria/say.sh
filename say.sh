#!/bin/bash

# System default language
SYSLNG="`echo $LANGUAGE | sed 's/_/-/g'`";

# Text file and audio files name that will be used by the script
P2WFILE="say";

# Set paths
ROOTPATH="$HOME/bin/say/"
SRCPATH="$ROOTPATH$P2WFILE.sh"
GUIPATH="$ROOTPATH${P2WFILE}gui.sh"
CFGPATH="$ROOTPATH$P2WFILE.cfg"
SNDPATH="$ROOTPATH$P2WFILE.wav"

# Accepted languages
P2WLNGS=( "en-GB" "en-US" "fr-FR" "de-DE" "it-IT" "es-ES" );
P2WLNGSNAME=( 'English (British)' 'English (US)' 'French' 'German' 'Italian' 'Spanish'  );

## Checks if language is supported by synthesiser
saysupport()
{
	re='^[a-z]{2}\-[A-Z]{2}$';

	if [ $# -eq 1 ]; then
		if ! [[ $1 =~ $re ]]; then
			return 0
		fi
		for i in "${P2WLNGS[@]}"; do
			if [[ "$i" = "$1" ]]; then
				return 1;
			fi
		done
	fi
	return 0;
}

# Get/Set program config: language, volume, speed
saycfg ()
{
	if [ $# -ge 1  ]; then
		saylng $1
		if [ $# -ge 2 ]; then
			sayvol $2
			if [ $# -ge 3 ]; then
				sayspd $3
			fi
		fi
	fi
	cat "$CFGPATH";
}

# Get/Set synthesiser lamguage
saylng ()
{
	cfg=( `cat $CFGPATH` );
	if ! [ $# -eq 1  ]; then
		echo "${cfg[0]}"; return;
	fi
	text=$1
	if [ $1 = "-d" ]; then
		text="`saydeflng`"
	fi
	saysupport $text;
	if [ $? -eq 1  ]; then
		cfg[0]="$text"
		echo "${cfg[*]}" > $CFGPATH
	else
		echo "\"$1\" is unsupported. Supported languages: ${P2WLNGS[*]}";
	fi
}

# Get/Set volume level
sayvol()
{
	cfg=( `cat $CFGPATH` )
	if [ $# -eq 1 ]; then
		re='^[0-2](\.[0-9])?$'
		if [[ $1 =~ $re ]]; then
			num=`echo "0 + $1" | bc`
			if [ `echo "$num >= 0 && $num <= 2" | bc`  -eq 1 ]; then
				cfg[1]="$num"
				echo "${cfg[*]}" > $CFGPATH
			fi
		fi
	else
		echo "${cfg[1]}"
	fi
}

# Get/Set speed level
sayspd()
{
	cfg=( `cat $CFGPATH` );
	if [ $# -eq 1 ]; then
		re='^[0-2](\.[0-9])?$'
		if [[ $1 =~ $re ]]; then
			num=`echo "0 + $1" | bc`
			if [ `echo "$num >= 0.5 && $num <= 1.5" | bc` -eq 1 ]; then
				cfg[2]="$num"
				echo "${cfg[*]}" > $CFGPATH
			fi
		fi
	else
		echo "${cfg[2]}"
	fi
}

# Get index of language in languages list
saylngindex()
{
	i=0;
	re='^[a-z]{2}\-[A-Z]{2}$';

	if [ $# -eq 1  ]; then
		if [[ $1 =~ $re ]]; then
			TEST=$1;
		fi
	fi
	if [ $TEST = "" ]; then
		TEST=`saylng`;
	fi
	for LNG in "${P2WLNGS[@]}"; do
		if [[ "$LNG" = "$TEST" ]]; then
			echo $i;
		fi
		i=`expr $i + 1`;
	done
}

# Get system language if supported or a default one
saydeflng()
{
	saysupport $SYSLNG
	if [ $? -eq 1 ]; then
		echo "$SYSLNG";
	else
		echo "en-US";
	fi
}

# Starts GUI window
saygui()
{
	$GUIPATH $1
}

# Stops audio playback
shutup ()
{
	killall -9 play;
}

# Start synthesiser
say ()
{
	cfg=`cat $CFGPATH`;
	IFS=', ' read -r -a cfg <<<  "$cfg";
	text=( "$@" );
	if [ $# -ge 2 ]; then
		if [ -f $2  ]; then
			unset text[1];
			tmp=`cat $2`;
			text=( "${text[@]}" "${tmp[@]}"  );
		fi
	fi
	if [ ! -t 0 ]; then
		while read -a line; do
			text=( "${text[@]}" "${line[@]}"  );
		done
	fi
	saysupport $1;
	if [[ $? -eq 1 ]]; then
		cfg[0]=$1;
		unset text[0];
	fi
	if [ `echo "${text[*]}" | wc -c` -eq 1 ]; then
		echo "Give me something to say!"
		return
	fi
	pico2wave -l ${cfg[0]} -w $SNDPATH "\"${text[*]}\"";
	play $SNDPATH vol ${cfg[1]} speed ${cfg[2]};
}

# Script related instructions
if [ "$1" = "config" ]; then
	saycfg $2 $3 $4;
elif [ "$1" = "gui" ]; then
	saygui $2;
elif [ "$1" = "say" ]; then
	if [ "`pgrep -x play`" > /dev/null ]; then
		shutup;
	else
		say "`xsel`" ;
	fi
elif [ "$1" = "install" ]; then
	if [ ! -d "$ROOTPATH" ]; then
		mkdir -p $ROOTPATH
		echo "Created directory: $ROOTPATH"
	fi
	if [ ! -f "$SRCPATH" ]; then
		cp ./$P2WFILE.sh $ROOTPATH
		cp ./${P2WFILE}gui.sh $ROOTPATH
		echo "Scripts copied to: $ROOTPATH directory"
	fi
	if [ ! -f "$CFGPATH" ]; then
		touch $CFGPATH
		echo -n "Default config set to: "
		saycfg "-d" 1 1;
	fi
	if [ ! "`grep -rnw $HOME/.bashrc -e \". $SRCPATH\"`" > /dev/null ]; then
		echo ". $SRCPATH" >> "$HOME/.bashrc"
		echo "Script autoload instruction added to $HOME/.bashrc"
		source "$HOME/.bashrc"
		echo "Reloaded source: $HOME/.bashrc"
	fi
	if [ "$2" = "-d" ]; then
		sudo apt-get install libttspico-utils sox zenity xsel;
	fi
elif [ "$1" = "uninstall" ]; then
	#cat "$HOME/.bashrc" | grep -v "$SRCPATH" > ~/.bashrc
	#echo "Script autoload instruction removed from $HOME/.bashrc"
	source "$HOME/.bashrc"
	echo "Reloaded source: $HOME/.bashrc"
	rm -rf "$ROOTPATH"
	echo "Directory removed: $ROOTPATH"
fi
