#!/bin/bash
#
# GRC-Netdata single line install with custom support.
#
# Supports:
#	Ubuntu/Debian
#
# Future Supports:
#	Fedora
#	openSUSE
#	REHL
#	ARCH
#	Anything else netdata and gridcoin support
#
# Set colors
TY="\033[1;32m[Y]\033[m"
TN="\033[1;33m[N]\033[m"
TD="\033[1;35m[-]\033[m"
TW="\033[1;33m[W]\033[m"
TI="\033[1;34m[I]\033[m"
TQ="\033[1;36m[?]\033[m"
TE="\033[1;31m[E]\033[m ERROR: "
TO="\033[1;m[>]\033[m"
#
# Hardcoded Values
GRCCONF="/usr/local/bin/grc-netdata.conf"
BINFOLDER="/usr/local/bin"
STD=" 1> /dev/null 2> setup.err"
#
# Functions here

# echo coloured out with proper output // Time saver!
function eo {

	# Easier to format echos :)
	# ARG 1 is type of message
	# ARG 2 is message
	if [[ "$1" == "Y" ]]
	then
		echo -e ${TY} ${2}
	elif [[ "$1" == "N" ]]
	then
		echo -e ${TN} ${2}
	elif [[ "$1" == "I" ]]
	then
		echo -e ${TI} ${2}
	elif [[ "$1" == "W" ]]
	then
		echo -e ${TW} ${2}
	elif [[ "$1" == "D" ]]
	then
		echo -e ${TD} ${2}
	elif [[ "$1" == "E" ]]
	then
		echo -e ${TE} ${2}
	elif [[ "$1" == "O" ]]
	then
		echo -e ${TO} ${2}
	else
		echo BAD SYNTAX ON EOUT
		exit 1
	fi
}

# Ask a question and place it in a value from outside of a function that I choose.
function ei {

	# Ask questions easier. Reply in substituted value?
	# $1 is type
	# $2 output string. ex value will become $value.
	# $3 is the question
	if [[ "$1" == "1" ]]
	then
		read -p "$(echo -e ${TQ}" ${3} ")" -n 1 "${2}"
		echo
		return 1
	elif [[ "$1" == "2" ]]
	then
		read -p "$(echo -e ${TQ}" ${3} ")" "${2}"
		return 1
	else
		echo BAD READ SYNTAX
		exit 1
	fi
}

# Root Check

function check_root {

	eo D "Checking UID.."
	checkroot=$(id -u)
	if [[ "$checkroot" == "0" ]]
	then
		eo I "DETECTED: UID=0 (root)"
		eo Y "Do we have root privilege?"
	else
		eo I "DETECTED: UID=$checkroot"
		eo N "Do we have root privilege?"
		eo E "This install needed root privileges."
		eo I "Try 'sudo ./setup.sh'"
		eo E "Exiting."
		exit 1
	fi

}

# Release check (2 methods)

function check_release {

	eo D "Checking release information."
	if [[ -a /usr/bin/lsb_release ]]
	then
		eo Y "Was lsb_release found?"
		osrelease=$(lsb_release -i | cut -d ":" -f2- | tr -d "\t")
		if [[ "$osrelease" == "Ubuntu" || "$osrelease" == "Debian" ]]
		then
			eo I "Release is $osrelease"
			eo I "Installing for Ubuntu/Debian."
			os="1"
			return 1
		else
			eo I "Release is $osrelease"
			eo E "$osrelease is currently not supported."
			eo E "Exiting."
			exit 1
		fi
	else
		eo N "Was lsb_release found?"
	fi
	eo D "List of supported releases:"
	eo O "1) Ubuntu/Debian"
	eo O "2) Not yet implemented"
	ei 1 os_release "Please select your distribution:"
	if [[ "$os_release" == "1" ]]
	then
		eo I "Installing for Ubuntu/Debian."
		os="1"
		return 1
	else
		eo E "Bad input."
		eo E "Exiting."
		exit 1
	fi

}

# To default of not to default that is the real question.

function gather_info {

	eo D "Gathering information about your setup."
	eo D
	ei 1 default "Would you like to use the default setup? (Y/N):"
	case "$default" in
		Y|y ) defaultcase="Y";;
		N|n ) defaultcase="N";;
	esac
	if [[ "$defaultcase" == "Y" ]]
	then
		eo I "User opted for default config."
		conf_exists
		if [[ "$keepconfigcase" == "Y" ]]
		then
			return 1
		else
			conf_reset
			conf_commit
			return 1
		fi
	elif [[ "$defaultcase" == "N" ]]
	then
		eo I "User opted for custom config."
		conf_exists
		if [[ "$keepconfigcase" == "Y" ]]
		then
			return 1
		else
			conf_gather
			return 1
		fi
	else
		echo E "Invalid selection, starting over."
		gather_info
		return 1
	fi

}

# conf_reset sets dafaults

function conf_reset {

	GRCUSER="gridcoin"
	GRCPATH="home/gridcoin/.Gridcoinresearch"
	GRCAPP="/usr/bin/gridcoinresearchd"
	FREEGEOIPPORT="5000"
	GETINFOTIMER="5s"
	GETINFODELAY="7min"
	GETGEOTIMER="15s"
	GETGEODELAY="7min"
	GETMARKETTIMER="15s"
	GETMARKETDELAY="7mins"
	return 1
}

# Check for dependencies for install and GRC-Netdata

function check_dep {

	eo D "Checking for dependencies.."
	if [[ -a /usr/bin/jq ]]
	then
		eo Y "Is 'jq' installed?"
	else
		eo N "Is 'jq' installed?"
		dep_jq
	fi
	if [[ -a /usr/bin/bc ]]
	then
		eo Y "Is 'bc' installed?"
	else
		eo N "Is 'bc' installed?"
		dep_bc
	fi
	if [[ -a $GRCAPP ]]
	then
		eo Y "Is gridcoin daemon found?"
	else
		eo N "Is gridcoin daemon found?"
		eo E "Must have gridcoin installed. Exiting."
		exit 1
	fi
	if [[ -a /usr/sbin/netdata ]]
	then
		eo Y "Is netdata installed?"
	else
		eo N "Is netdata installed?"
		eo E "Must have netdata installed. Exiting."
		exit 1
	fi
	if [[ -a /bin/systemd ]]
	then
		eo Y "Is systemd installed?"
}

# Does config file exist? If so what shall you do!

function conf_exists {
	eo D "Checking for existing config."
	if [[ -a $GRCCONF ]]
	then
		eo Y "Does $GRCCONF already exist?"
		ei 1 keepconfig "Would you like to keep your existing config? (Y/N):"
		case "$keepconfig" in
			Y|y ) keepconfigcase="Y";;
			N|n ) keepconfigcase="N";;
		esac
		if [[ "$keepconfigcase" == "Y" ]]
		then
			eo I "Keeping config as requested. Resuming install."
			return 1
		elif [[ "$keepconfigcase" == "N" ]]
		then
			eo I "Removing previous config as requested."
			rm -f "$GRCCONF" "$STD"
			return 1
		else
			eo E "Bad input. Try again."
			conf_exists
			return 1
		fi
	else
		eo N "Does $GRCCONF already exist?"
		return 1
	fi
}

# conf_set_useraccount seperated these so user wouldn't have to re go through config.
# Not most ideal but better then messing up one of last values and having to start over.
# Yea I could make a routine help people make bash look more like assembly?? But no room for a troll ;)

function conf_set_grcuser {

	GRCUSER="gridcoin"
	confgrcuser="0"
        ei 2 confanswer "What account is running the gridcoin client? (Default = gridcoin):"
        if [[ "$confanswer" == "" ]]
        then
                GRCUSER="gridcoin"
        else
                GRCUSER="$confanswer"
        fi
        eo I "Using account $GRCUSER."
        while read -r passwdline; do
                passwdlineparse="${passwdline%%:*}"
                if [[ "$passwdlineparse" == "$GRCUSER" ]]
                then
                        confgrcuser="1"
                        break
                fi
        done < /etc/passwd
        if [[ "$confgrcuser" == "0" ]]
        then
                eo N "Does account $GRCUSER exist?"
                eo E "No account $GRCUSER found. Let's start again."
                conf_set_grcuser
                return 1
        elif [[ "$confgrcuser" == "1" ]]
        then
                eo Y "Does account $GRCUSER exist?"
        else
                eo E "Unexpected error. Lets try again."
                conf_set_grcuser
                return 1
        fi

}

# conf_set_grcpath

function conf_set_grcpath {

        ei 2 confanswer "What is the path of the gridcoin data directory? (Default = /home/$GRCUSER/.GridcoinResearch) :"
        if [[ "$confanswer" == "" ]]
        then
                GRCPATH="/home/$GRCUSER/.GridcoinResearch"
                eo I "Using default of /home/$GRCUSER/.GridcoinResearch"
        else
                GRCPATH="$confanswer"
        fi
	eo I "Checking path $GRCPATH."
        if [[ -d $GRCPATH ]]
        then
                eo Y "Does $GRCPATH exist?"
		return 1
        else
                eo N "Does $GRCPATH exist?"
                eo E "$GRCPATH not found. Lets try again."
		conf_set_grcpath
		return 1
	fi

}

# conf_set_grcapp

function conf_set_grcapp {

        ei 2 confanswer "What is the location of gridcoinresearchd? (Default = /usr/bin/gridcoinresearchd) :"
        if [[ "$confanswer" == "" ]]
        then
                GRCAPP="/usr/bin/gridcoinresearchd"
                eo I "Using default of /usr/bin/gridcoinresearchd"
        else
                GRCAPP="$confanswer"
        fi
        eo I "Checking for $GRCAPP."
        if [[ -a $GRCAPP ]]
        then
                eo Y "Does $GRCAPP exist?"
                return 1
        else
                eo N "Does $GRCAPP exist?"
                eo E "$GRCAPP not found. Lets try again."
                conf_set_grcapp
                return 1
        fi

}

# conf_set_freegeoipport

function conf_set_freegeoipport {

	eo W "Port needs to be set inbetween port 1025 and 65534. Port 1024 and less is reserved for root."
        ei 2 confanswer "What port on local loopback would you like to use with freegeoip API? (Default = 5000) :"
        if [[ "$confanswer" == "" ]]
        then
                FREEGEOIPPORT="5000"
                eo I "Using default of port 5000."
        else
                FREEGEOIPPORT="$confanswer"
        fi
        eo I "Checking port value $FREEGEOIPPORT."
	if [[ "$FREEGEOIPPORT" =~ ^[0-9]+$ ]]
	then
	        if [[ $FREEGEOIPPORT -ge 1025 && $FREEGEOIPPORT -le 65534 ]]
	        then
	                eo Y "Is $FREEGEOIPPORT valid?"
			FREEGEOIPPORT="$FREEGEOIPPORT"
	                return 1
	        else
	                eo N "Is port $FREEGEOIPPORT valid?"
	                eo E "$FREEGEOIPPORT is not in valid range of 1025-65534. Lets try again."
	                conf_set_freegeoipport
	                return 1
		fi
	else
		eo E "$FREEGEOIPPORT is not a valid numeric value. Lets try again"
		conf_set_freegeoipport
		return 1
        fi

}

# conf_set_getinfotimer

function conf_set_getinfotimer {

	ei 2 confanswer "How often should the base gridcoin chart gather updates (Default = 5s):"
	if [[ "$confanswer" == "" ]]
	then
		GETINFOTIMER="5s"
		eo I "Using default of 5s."
	else
		GETINFOTIMER="$confanswer"
	fi
	eo I "Checking is $GETINFOTIMER is valid entry."
	if [[ ${GETINFOTIMER%%s} =~ ^[0-9]+$ && "$GETINFOTIMER" == *s ]]
	then
		eo Y "$GETINFOTIMER is a valid entry."
		return 1
	else
		eo N "$GETINFOTIMER is a valid entry."
		eo E "Bad input! Lets try again"
		conf_set_getinfotimer
		return 1
	fi

}

# conf_set_getinfodelay

function conf_set_getinfodelay {

        ei 2 confanswer "How long of a delay after netdata starts should gridcoin chart gathering begin (Default = 7min):"
        if [[ "$confanswer" == "" ]]
        then
                GETINFODELAY="7min"
                eo I "Using default of 7min."
        else
                GETINFODELAY="$confanswer"
        fi
        eo I "Checking is $GETINFODELAY is valid entry."
        if [[ ${GETINFODELAY%%min} =~ ^[0-9]+$ && "$GETINFODELAY" == *min ]]
        then
                eo Y "$GETINFODELAY is a valid entry."
		return 1
        else
                eo N "$GETINFODELAY is not a valid entry."
		eo E "Bad input! Lets try again."
                conf_set_getinfodelay
                return 1
        fi

}

# conf_set_getgeotimer

function conf_set_getgeotimer {

        ei 2 confanswer "How often should geography of peers gather updates (Default = 15s):"
        if [[ "$confanswer" == "" ]]
        then
                GETGEOTIMER="15s"
                eo I "Using default of 15s."
        else
                GETGEOTIMER="$confanswer"
        fi
        eo I "Checking is $GETGEOTIMER is valid entry."
        if [[ ${GETGEOTIMER%%s} =~ ^[0-9]+$ && "$GETGEOTIMER" == *s ]]
        then
                eo Y "$GETGEOTIMER is a valid entry."
                return 1
        else
                eo N "$GETGEOTIMER is a valid entry."
                eo E "Bad input! Lets try again"
                conf_set_getgeotimer
                return 1
        fi

}

# conf_set_getgeodelay

function conf_set_getgeodelay {

        ei 2 confanswer "How long of a delay after netdata starts should geography of peers begin updates (Default = 7min):"
        if [[ "$confanswer" == "" ]]
        then
                GETGEODELAY="7min"
                eo I "Using default of 7min."
        else
                GETGEODELAY="$confanswer"
        fi
        eo I "Checking is $GETGEODELAY is valid entry."
        if [[ ${GETGEODELAY%%min} =~ ^[0-9]+$ && "$GETGEODELAY" == *min ]]
        then
                eo Y "$GETGEODELAY is a valid entry."
                return 1
        else
                eo N "$GETGEODELAY is not a valid entry."
                eo E "Bad input! Lets try again."
                conf_set_getgeodelay
                return 1
        fi

}

# conf_set_getmarkettimer

function conf_set_getmarkettimer {

        ei 2 confanswer "How often should market chart gather updates (Default = 15s):"
        if [[ "$confanswer" == "" ]]
        then
                GETMARKETTIMER="15s"
                eo I "Using default of 15s."
        else
                GETMARKETTIMER="$confanswer"
        fi
        eo I "Checking is $GETMARKETTIMER is valid entry."
        if [[ ${GETMARKETTIMER%%s} =~ ^[0-9]+$ && "$GETMARKETTIMER" == *s ]]
        then
                eo Y "$GETMARKETTIMER is a valid entry."
                return 1
        else
                eo N "$GETMARKETTIMER is a valid entry."
                eo E "Bad input! Lets try again"
                conf_set_getmarkettimer
                return 1
        fi

}

# conf_set_getmarketdelay

function conf_set_getmarketdelay {

        ei 2 confanswer "How long of a delay after netdata starts should market chart begin updates (Default = 7min):"
        if [[ "$confanswer" == "" ]]
        then
                GETMARKETDELAY="7min"
                eo I "Using default of 7min."
        else
                GETMARKETDELAY="$confanswer"
        fi
        eo I "Checking is $GETMARKETDELAY is valid entry."
        if [[ ${GETMARKETDELAY%%min} =~ ^[0-9]+$ && "$GETMARKETDELAY" == *min ]]
        then
                eo Y "$GETMARKETDELAY is a valid entry."
                return 1
        else
                eo N "$GETMARKETDELAY is not a valid entry."
                eo E "Bad input! Lets try again."
                conf_set_getmarketdelay
                return 1
        fi

}

# Gather config

function conf_gather {

	conf_reset
	eo D
        eo D "Lets gather information about your custom setup."
	eo I "If you leave the value empty the default option will be selected."
	eo D
	conf_set_grcuser
	conf_set_grcpath
	conf_set_grcapp
	conf_set_freegeoipport
	eo D "Lets set systemd timer/dealys"
        eo W "Service timers must be set as #s. Example 5s"
	eo W "Service delays must be set as #min. Example 7min"
	eo W "This install only supports seconds and minutes as it is pointless to be higher then that."
	eo W "Delays are default 7min to allow time for gridcoin daemon to fully start as it takes time."
	conf_set_getinfotimer
	conf_set_getinfodelay
	conf_set_getgeotimer
	conf_set_getgeodelay
	conf_set_getmarkettimer
	conf_set_getmarketdelay
	conf_commit
	return 1
}

function conf_commit {

	eo D "Writing config. Config file is location is /usr/local/bin/grc-netdata.conf"
	echo "GRCUSER=$GRCUSER" > $GRCCONF
	echo "GRCPATH=$GRCPATH" >> $GRCCONF
	echo "GRCAPP=$GRCAPP" >> $GRCCONF
	echo "FREEGEOIPPORT=$FREEGEOIPPORT" >> $GRCCONF
	echo "Note1=This config only has basics it needs" >> $GRCCONF
	echo "Note2=If you change this config make sure you restart the corresponding service or application." >> $GRCCONF
	echo "Note3=Systemd timer/delays are in /etc/systemd/system/" >> $GRCCONF
	echo "Note4=If you change FREEGEOIPPORT you must also edit contrab for GRCUSER to the updated port." >> $GRCCONF
	eo D "Written config file."
	return 1
}

# Start here

echo
echo
eo D "Welcome to GRC-Netdata installation."
eo D
eo I "STDERR information is stored in setup.err"
eo D
eo D "Running preinstall checks."
eo D
check_root
check_release
gather_info
check_dep
