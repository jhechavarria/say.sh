#!/bin/bash

# Base paths
P2WFILE="say"
ROOTPATH="$HOME/bin/say/"
SRCPATH="$ROOTPATH$P2WFILE.sh"
GUIPATH="$ROOTPATH$P2WFILEgui.sh"
CFGPATH="$ROOTPATH$P2WFILE.cfg"

# Main title
TITLE="SayGUI"

# Load base functions
. "$SRCPATH"

sayguimenu()
{
	while true
	do
		WINDOW=`zenity --list \
				--width=640 --height=480 \
				--title="$TITLE | Main menu" \
				--ok-label="Open" \
				--cancel-label="Exit" \
				--hide-column=1 \
				--hide-header \
				--column="Action" --column="Menu Option" \
				"tts" "Say something!"\
				"lng" "Language Settings" \
				"vol" "Volume Settings" \
				"spd" "Speed Settings"`

		case $? in
				0)
					if [ "$WINDOW" = "tts" ]; then
						sayguitts
					elif [ "$WINDOW" = "lng" ]; then
						sayguilng
					elif [ "$WINDOW" = "vol" ]; then
						sayguivol
					elif [ "$WINDOW" = "spd" ]; then
						sayguispd
					fi;;
				1)
					sayguinotif "Aucune valeur sélectionnée.";
					break;;
				-1)
					sayguinotif "Une erreur inattendue est survenue.";
					break;;
		esac
	done
}

sayguitts()
{
	while true
	do
		TEXT=`zenity --entry \
			--width=640 --height=480 \
			--title="$TITLE | Say something!" \
			--text="Type anything you wish to be read:" \
			--ok-label="Save" \
			--cancel-label="Close" \
			--entry-text "$TEXT"`
		case $? in
				0)
					echo "$TEXT"
					if ! [ "$TEXT" = "" ]; then
						say "$TEXT"
					fi;;
				1)
					sayguinotif "Aucune valeur sélectionnée.";
					break;;
				-1)
					sayguinotif "Une erreur inattendue est survenue.";
					break;;
		esac
	done
}

sayguilng()
{
	LANGUAGE=`zenity --list \
			--width=640 --height=480 \
			--title="$TITLE | Language Settings" \
			--ok-label="Save" \
			--cancel-label="Close" \
			--hide-column=1 \
			--hide-header \
			--column="" --column="Language" \
			"en-US" "English (US)" \
			"en-GB" "English (GB)" \
			"fr-FR" "French" \
			"de-DE" "Deutsch" \
			"es-ES" "Spanish" \
			"it-IT" "Italian"`

	case $? in
			0)
				if ! [ "$LANGUAGE" = "" ]; then
					saylng "$LANGUAGE"
					sayguinotif "Vous avez choisi $LANGUAGE."
				fi;;
			1)
				sayguinotif "Aucune valeur sélectionnée.";;
			-1)
				sayguidial "Une erreur inattendue est survenue." "error";;
	esac
}

sayguivol()
{
	cfg=( `cat $CFGPATH` )
	vol=`echo "${cfg[1]} * 100" | bc`
	VOLUME=`zenity --scale --title="$TITLE | Volume Settings" \
			--width=640 --height=480 \
			--text="Set new volume level" \
			--ok-label="Save" \
			--cancel-label="Close" \
			--value=$vol --min-value=0 --max-value=200 --step=1`
	case $? in
			0)
				if ! [ "$VOLUME" = "" ]; then
					sayvol "`echo \"$VOLUME / 100\" | bc`"
					sayguinotif "Vous avez choisi $VOLUME%."
				fi;;
			1)
				sayguinotif "Aucune valeur sélectionnée.";;
			-1)
				sayguidial "Une erreur inattendue est survenue." "error";;
	esac
}

sayguispd()
{
	cfg=( `cat $CFGPATH` )
	spd=`echo "${cfg[1]} * 100" | bc`
	SPEED=`zenity --scale --title="$TITLE | Speed Settings" \
			--width=640 --height=480 \
			--text="Set new speed level" \
			--ok-label="Save" \
			--cancel-label="Close" \
			--value=$spd --min-value=50 --max-value=150 --step=1`
	case $? in
			0)
				if ! [ "$SPEED" = "" ]; then
					sayspd "`echo \"$SPEED / 100\" | bc`"
					sayguinotif "Vous avez choisi $SPEED%."
				fi;;
			1)
				sayguinotif "Aucune valeur sélectionnée.";;
			-1)
				sayguidial "Une erreur inattendue est survenue." "error";;
	esac
}

sayguinotif()
{
	zenity --notification\
    --window-icon="info" \
    --text="$1"
}

sayguidial()
{
	if [ $# -ge 1 ]; then
		TYPE=$2
		if [ $TYPE = "" ]; then
			TYPE="info"
		fi
		if [ $TYPE = "info" ]; then
			zenity --info --text="$1"
		fi
		if [ $TYPE = "warning" ]; then
			zenity --warning --text="$1"
		fi
		if [ $TYPE = "error" ]; then
			zenity --error --text="$1"
		fi
		if [ $TYPE = "question" ]; then
			zenity --question --text="$1"
			return $?
		fi
	fi
}

if [ $# -eq 1 ]; then
	if [ $1 = "tts" ]; then
		sayguitts
	elif [ $1 = "lng" ]; then
		sayguilng
	elif [ $1 = "vol" ]; then
		sayguivol
	elif [ $1 = "spd" ]; then
		sayguispd
	else
		sayguimenu
	fi
else
	sayguimenu
fi
