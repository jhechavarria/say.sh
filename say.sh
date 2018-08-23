#!/bin/bash

# Text file and audio files name that will be used by the script
P2WFILE="say";

# Set paths
ROOTPATH="$HOME/bin/say/"
SRCPATH="$ROOTPATH$P2WFILE.sh"
CFGPATH="$ROOTPATH$P2WFILE.cfg"
SNDPATH="$ROOTPATH$P2WFILE.wav"

# Accepted languages
P2WLNGS=( "en-GB" "en-US" "fr-FR" "de-DE" "it-IT" "es-ES" );
P2WLNGSNAME=( 'English (British)' 'English (US)' 'French' 'German' 'Italian' 'Spanish'  );

## Checks if language is supported by synthesiser
saysupport()
{
	for i in "${P2WLNGS[@]}"; do
		if [[ "$i" = "$1" ]]; then
			return 1;
		fi
	done
	return 0;
}

# Get/Set program config: language, volume, speed
saycfg ()
{
	cfg=`cat $CFGPATH`;
	IFS=', ' read -r -a cfg <<<  "$cfg";
	if [ $# -ge 1  ]; then
		saysupport $1;
		if [ $? -eq 1  ]; then
			cfg[0]="$1";
		fi
	fi
	if [ $# -ge 2 ]; then
		num=`echo "0 + $2" | bc`;
		if [ `echo "$num >= 0 && $num <= 2" | bc`  -eq 1 ]; then
			cfg[1]="$num";
		fi
	fi
	if [ $# -ge 3 ]; then
		num=`echo "0 + $3" | bc`;
		if [ `echo "$num >= 0.5 && $num <= 1.5" | bc` -eq 1 ]; then
			cfg[2]="$num";
		fi
	fi
	if [ $# -ge 1 ]; then
		echo "${cfg[*]}" > $CFGPATH;
	fi
	echo "${cfg[*]}";
}

# Get/Set synthesiser lamguage
saylng ()
{
	cfg=( `cat $CFGPATH` );
	IFS=', ' read -r -a cfg <<<  "$cfg";
	if [ $# -eq 1  ]; then
		saysupport $1;
		if [ $? -eq 1  ]; then
			saycfg "$1"
		else
			echo "\"$1\" is unsupported. Supported languages: ${P2WLNGS[*]}";
		fi
	else
		echo "${cfg[0]}";
	fi
}

# Get/Set volume level
sayvol()
{
	cfg=( `cat $CFGPATH` )
	if [ $# -ge 1 ]; then
		num=`echo "0 + $1" | bc`
		if [ `echo "$num >= 0 && $num <= 2" | bc`  -eq 1 ]; then
			cfg[1]="$num"
			echo "${cfg[*]}" > $CFGPATH
		fi
	else
		echo "${cfg[1]}"
	fi
}

# Get/Set speed level
sayspd()
{
	cfg=( `cat $CFGPATH` );
	if [ $# -ge 1 ]; then
		num=`echo "0 + $1" | bc`
		if [ `echo "$num >= 0.5 && $num <= 1.5" | bc` -eq 1 ]; then
			cfg[2]="$num"
			echo "${cfg[*]}" > $CFGPATH
		fi
	else
		echo "${cfg[2]}"
	fi
}

# Get index of language in languages list
saylngindex()
{
	i=0;

	if [ $# -eq 1  ]; then
		TEST=$1;
	else
		TEST=`saylng`;
	fi
	for LNG in "${P2WLNGS[@]}"; do
		if [[ "$LNG" = "$TEST" ]]; then
			echo $i;
			return 1;
		fi
		i=`expr $i + 1`;
	done
	return 0;
}

# Stops audio playback
shutup ()
{
	killall play;
}

# Start synthesiser
say ()
{
	cfg=`cat $CFGPATH`;
	IFS=', ' read -r -a cfg <<<  "$cfg";
	text=( "$@" );
	if [ $# -ge 2 -a -f $2  ]; then
		unset text[1];
		tmp=`cat $2`;
		text=( "${text[@]}" "${tmp[@]}"  );
	fi
	if [ -t 0 ]; then
		echo "Interactive Mode";
	else
		while read -a line; do
			text=( "${text[@]}" "${line[@]}"  );
		done
	fi
	saysupport $1;
	if [[ "$?" = "1" ]]; then
		cfg[0]=$1;
		unset text[0];
	fi
	pico2wave -l ${cfg[0]} -w $SNDPATH "${text[*]}";
	play $SNDPATH vol ${cfg[1]} speed ${cfg[2]};
}

if [[ "$1" = "install"  ]]; then
	if [ ! -d "$ROOTPATH" ]; then
		mkdir -p $ROOTPATH
		echo "Created directory: $ROOTPATH"
	fi
	if [ ! -f "$SRCPATH" ]; then
		mv ./$P2WFILE.sh $ROOTPATH
		echo "Script moved to: $ROOTPATH directory"
	fi
	if [ ! -f "$CFGPATH" ]; then
		SYSLNG="`echo $LANGUAGE | sed 's/_/-/g'`";
		touch $CFGPATH
		echo -n "Default config set to: "
		saysupport $SYSLNG
		if [ $? -eq 1 ]; then
			saycfg "$SYSLNG" 1 1;
		else
			saycfg "en-US" 1 1;
		fi
	fi
	if [ ! "`grep -rnw $HOME/.bashrc -e \". $SRCPATH\"`" > /dev/null ]; then
		echo ". $SRCPATH" >> "$HOME/.bashrc"
		echo "Script autoload instruction added to $HOME/.bashrc"
		source "$HOME/.bashrc"
		echo "Reloaded source: $HOME/.bashrc"
	fi
	if [ "$2" = "d" ]; then
		sudo apt-get install libttspico-utils sox dialog xsel;
	fi
elif [ "$1" = "config" ]; then
	saycfg $2 $3 $4;
elif [ "$1" = "lang" ] ; then
	DIALOG=${DIALOG=dialog}
	 fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
	trap "rm -f $fichtemp" 0 1 2 5 15
	$DIALOG --clear --title "T - Language" \
		--menu "Selct synthesiser defaul laguage" 20 51 10 \
			"en-GB" "English (British)" \
			"en-US" "English (US)" \
			"fr-FR" "French" \
			"de-DE" "German" \
			"it-IT" "Italan" \
			"es-ES" "Spanish" 2> $fichtemp
	valret=$?
	choix=`cat $fichtemp`
	case $valret in
		 0)
			saylng $choix;
			$DIALOG --clear --title "TS - Languge" \
				--msgbox "${P2WLNGSNAME[`saylngindex $choix`]} is now your default langue." 10 50;
		 ;;
		 1)
			$DIALOG --clear --title "TS - Languge" \
				--msgbox "${P2WLNGSNAME[`saylngindex`]} remains your default langue." 10 50;
		 ;;
		255)
			$DIALOG --clear --title "TS - Languge" \
				--msgbox "${P2WLNGSNAME[`saylngindex`]} remains your default langue." 10 50;
		;;
	esac
	clear
elif [ "$1" = "say" ]; then
	if [ "`pgrep -x play`" > /dev/null ]; then
		shutup;
	else
		TEXT=`xsel`;
		echo "$TEXT" | say;
	fi
fi
