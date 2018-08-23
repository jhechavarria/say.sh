#!/bin/bash

# Base paths
P2WFILE="say"
ROOTPATH="$HOME/bin/say/"
SRCPATH="$ROOTPATH$P2WFILE.sh"
GUIPATH="$ROOTPATH$P2WFILEgui.sh"
CFGPATH="$ROOTPATH$P2WFILE.cfg"

# Main title
TITLE="SayGUI Config"

# Load base functions
. "$SRCPATH"

sayguimenu()
{
	while true
	do
		VALUE=`zenity --list \
		  --title="$TITLE | Main menu" \
		  --column="action" --column="Name" \
		    "say" "Say something!"\
		    "lng" "Change language" \
		    "vol" "Change volume" \
		    "spd" "Change speed"`

		case $? in
				0)
					if [ $VALUE = "say" ]; then
						sayguisay
					elif [ $VALUE = "lng" ]; then
						sayguilng
					elif [ $VALUE = "vol" ]; then
						sayguivol
					elif [ $VALUE = "spd" ]; then
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

sayguisay()
{
	while true
	do
		VALUE=`zenity --entry \
			--title="$TITLE | Say something!" \
			--text="Type anything you wish to be read:" \
			--entry-text "$VALUE"`
		case $? in
				0)
					say "$VALUE";;
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
	VALUE=`zenity --list \
	  --title="$TITLE | Language" --radiolist  \
	  --column="" --column="Name" \
	    "en-US" "English (US)" \
	    "en-GB" "English (GB)" \
	    "fr-FR" "French" \
	    "de-DE" "Deutsch" \
	    "es-ES" "Spanish" \
	    "it-IT" "Italian"`

	case $? in
			0)
				saylng "$VALUE"
				sayguinotif "Vous avez choisi $VALUE.";;
			1)
				sayguinotif "Aucune valeur sélectionnée.";;
			-1)
				sayguidial "Une erreur inattendue est survenue." "error";;
	esac
}

sayguivol()
{
	VALUE=`zenity --scale --title="$TITLE | Volume" --text="Set new volume level" --value=100 --min-value=0 --max-value=200 --step=1`

	case $? in
			0)
				sayvol "`echo \"$VALUE / 100\" | bc`"
				sayguinotif "Vous avez choisi $VALUE%.";;
			1)
				sayguinotif "Aucune valeur sélectionnée.";;
			-1)
				sayguidial "Une erreur inattendue est survenue." "error";;
	esac
}

sayguispd()
{
	VALUE=`zenity --scale --title="$TITLE | Speed" --text="Set new speed level" --value=100 --min-value=50 --max-value=150 --step=1`

	case $? in
			0)
				sayspd "`echo \"$VALUE / 100\" | bc`"
				sayguinotif "Vous avez choisi $VALUE%.";;
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
			echo `zenity --question --text="$1"`
		fi
	fi
}

if [ $# -eq 1 ]; then
	if [ $1 = "say" ]; then
		sayguisay
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
