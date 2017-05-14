#!/bin/bash
#
# GRC-Netdata single line install with custom support.
#
# Supports:
#	Ubuntu/Debian
#
# Needs testing:
#	Fedora
#	openSUSE
#	ARCH
#
# Future Supports:
#	REHL
#	Anything else netdata and gridcoin support. If you know a release please do tell me as well as any information about dependecy packages,etc.
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
	return 1
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
	return 1

}

# Release check (5 releases -- need to be tested!) outputs as Ubuntu Debian Fedora SUSE LINUX / Arch

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
		elif [[ "$osrelease" == "Fedora" ]]
		then
			eo I "Release is $osrelease"
			eo I "Installing for Fedora."
			os="2"
			return 1
                elif [[ "$osrelease" == "SUSE LINUX" ]]
                then
                        eo I "Release is $osrelease"
                        eo I "Installing for SUSE LINUX."
                        os="3"
                        return 1
                elif [[ "$osrelease" == "Arch" ]]
                then
                        eo I "Release is $osrelease"
                        eo I "Installing for Arch."
                        os="4"
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
	eo O "2) Fedora"
	eo O "3) SUSE LINUX"
	eo O "4) ARCH"
	ei 1 os_release "Please select your distribution:"
	if [[ "$os_release" == "1" ]]
	then
		eo I "Installing for Ubuntu/Debian."
		os="1"
		return 1
	elif [[ "$osrelease" == "2" ]]
	then
		eo I "Installing for Fedora."
		os="2"
		return 1
        elif [[ "$osrelease" == "3" ]]
        then
                eo I "Installing for SUSE LINUX."
                os="3"
                return 1
        elif [[ "$osrelease" == "4" ]]
        then
                eo I "Installing for ARCH."
                os="4"
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
	conf_exists
	if [[ "$keepconfigcase" == "Y" ]]
	then
		return 1
	fi
        conf_reset
        conf_gather
        conf_commit
	return 1
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
			rm -f "$GRCCONF"
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
	return 1

}

# conf_commit just as it sounds.

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

# Check for dependencies for install and GRC-Netdata

function check_dep {

	if [[ "$os" == "1" ]]
	then
		if [[ -a /usr/bin/apt-get ]]
		then
			eo D "Updating apt-get."
			apt-get update >> setup.log 2>> setup.err
		else
			eo E "apt-get not installed. Exiting."
			exit 1
		fi
	elif [[ "$os" == "2" ]]
	then
                if [[ -a /bin/dnf ]]
                then
                        eo D "Updating dnf."
                        dnf update >> setup.log 2>> setup.err
                else
                        eo E "dnf not installed. Exiting."
                        exit 1
                fi
	elif [[ "$os" == "3" ]]
	then
		if [[ -a /usr/bin/zypper ]]
		then
			eo D "Updating zypper."
			zypper update >> setup.log 2>> setup.err
		else
			eo E "zypper not installed. Exiting."
			exit 1
		fi
	elif [[ "$os" == "4" ]]
	then
		if [[ -a /usr/bin/pacman ]]
		then
			eo D "Updating pacman."
			pacman update >> setup.log 2>> setup.err
		else
			eo E "pacman not installed. Exiting."
			exit 1
		fi
	else
		# Future additions here
		exit 1
	fi
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
                eo Y "Is 'systemd' installed?"
	else
		eo N "Is 'systemd' installed?"
		eo E "systemd is required for this install. Exiting."
		exit 1
	fi
	if [[ -a /usr/bin/curl ]]
	then
		eo Y "Is 'curl' installed?"
	else
		eo N "Is 'curl' installed?"
		dep_curl
	fi
	if [[ -a /usr/bin/pgrep ]]
	then
		eo Y "Is 'pgrep' of procps installed?"
	else
		eo N "Is 'pgrep' of procps installed?"
		dep_procps
	fi
	if [[ -a /usr/bin/crontab ]]
	then
		eo Y "Is 'crontab' installed?"
	else
		eo N "Is 'crontab' installed?"
		eo E "crontab is required for this install. Exiting."
		exit 1
	fi
	if [[ -a /usr/bin/wget ]]
	then
		eo Y "Is 'wget' installed?"
	else
		eo N "Is 'wget' installed?"
		dep_wget
	fi
	return 1
}

# install bc

function dep_bc {

	if [[ "$os" == "1" ]]
	then
		eo D "Installing 'bc' with apt-get."
		apt-get -y install bc >> setup.log 2>> setup.err
		eo D "Done."
	elif [[ "$os" == "2" ]]
	then
		eo D "Installing 'bc' with dnf."
		dnf -y install bc >> setup.log 2>> setup.err
		eo D "Done."
        elif [[ "$os" == "3" ]]
        then
                eo D "Installing 'bc' with zypper."
                zypper -y install bc >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "4" ]]
        then
                eo D "Installing 'bc' with pacman."
                pacman --noconfirm install bc >> setup.log 2>> setup.err
                eo D "Done."
	else
		# Future additions here
		exit 1
	fi
	return 1

}

# install jq

function dep_jq {

	if [[ "$os" == "1" ]]
	then
		eo D "Installing 'jq' with apt-get."
		apt-get -y install jq >> setup.log 2>> setup.err
		eo D "Done"
        elif [[ "$os" == "2" ]]
        then
                eo D "Installing 'jq' with dnf."
                dnf -y install jq >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "3" ]]
        then
                eo D "Installing 'jq' with zypper."
                zypper -y install jq >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "4" ]]
        then
                eo D "Installing 'jq' with pacman."
                pacman --noconfirm install jq >> setup.log 2>> setup.err
                eo D "Done."
        else
                # Future additions here
                exit 1
	fi
	return 1

}

# install curl

function dep_curl {

	if [[ "$os" == "1" ]]
	then
		eo D "Installing 'curl' with apt-get."
		apt-get -y install curl >> setup.log 2>> setup.err
		eo D "Done."
        elif [[ "$os" == "2" ]]
        then
                eo D "Installing 'curl' with dnf."
                dnf -y install curl >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "3" ]]
        then
                eo D "Installing 'curl' with zypper."
                zypper -y install curl >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "4" ]]
        then
                eo D "Installing 'curl' with pacman."
                pacman --noconfirm install curl >> setup.log 2>> setup.err
                eo D "Done."
        else
                # Future additions here
                exit 1
	fi
	return 1

}

# Install procps for pgrep

function dep_procps {

	if [[ "$os" == "1" ]]
	then
		eo D "Installing 'pgrep' from procps with apt-get."
		apt-get -y install procps >> setup.log 2>> setup.err
		eo D "Done."
        elif [[ "$os" == "2" ]]
        then
                eo D "Installing 'pgrep' from procps-ng with dnf."
                dnf -y install procps-ng >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "3" ]]
        then
                eo D "Installing 'pgrep' from procps with zypper."
                zypper -y install procps >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "4" ]]
        then
                eo D "Installing 'pgrep' from procps-ng with pacman."
                pacman --noconfirm install procps-ng >> setup.log 2>> setup.err
                eo D "Done."
        else
                # Future additions here
                exit 1
	fi
	return 1

}

# install wget

function dep_wget {

	if [[ "$os" == "1" ]]
	then
		eo D "Installing 'wget' with apt-get."
		apt-get -y install wget >> setup.log 2>> setup.err
		eo D "Done."
        elif [[ "$os" == "2" ]]
        then
                eo D "Installing 'wget' with dnf."
                dnf -y install wget >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "3" ]]
        then
                eo D "Installing 'wget' with zypper."
                zypper -y install wget >> setup.log 2>> setup.err
                eo D "Done."
        elif [[ "$os" == "4" ]]
        then
                eo D "Installing 'wget' with pacman."
                pacman --noconfirm install wget >> setup.log 2>> setup.err
                eo D "Done."
        else
                # Future additions here
                exit 1
	fi
	return 1

}

# install charts

function install_charts {

	eo D "Installing charts."
	CHARTS="/usr/libexec/netdata/charts.d"
	cp -f gridcoinmain.chart.sh $CHARTS
	cp -f gridcoinmarket.chart.sh $CHARTS
	eo D "Making charts executable."
	chmod +x $CHARTS/gridcoinmain.chart.sh
	chmod +x $CHARTS/gridcoinmarket.chart.sh
	eo D "Done."
	return 1

}

# install scripts

function install_scripts {

	eo D "Installing scripts."
	cp -f gridcoinmain.sh "$BINFOLDER/gridcoinmain.sh"
	cp -f gridcoinmarket.sh "$BINFOLDER/gridcoinmarket.sh"
	cp -f gridcoingeo.sh "$BINFOLDER/gridcoingeo.sh"
	eo D "Making scripts executable."
	chmod +x "$BINFOLDER/gridcoinmain.sh"
	chmod +x "$BINFOLDER/gridcoinmarket.sh"
	chmod +x "$BINFOLDER/gridcoingeo.sh"
	eo D "Done."
	return 1

}

# install freegeoip + license + geo.json

function install_freegeoip {

	eo D "Installing freegeoip v3.2, license and geo.json translation file."
	if [[ "$os" == "1" ]]
	then
		ARCHIVE='freegeoip-3.2-linux-amd64'
		eo D "Downloading from fiorix/freegeoip on github."
		wget https://github.com/fiorix/freegeoip/releases/download/v3.2/"$ARCHIVE".tar.gz >> setup.log 2>> setup.err
		eo D "Extracting archive."
		tar -zxf "$ARCHIVE".tar.gz "$ARCHIVE"/freegeoip
		eo D "Installing files."
		cp -f "$ARCHIVE"/freegeoip "$BINFOLDER"
		cp -f geo.json "$BINFOLDER"
		cp -f freegeoip.license "$BINFOLDER"
		eo D "Removing archive."
		rm -rf "$ARCHIVE"
		rm -f "$ARCHIVE".tar.gz
		eo D "done."
		return 1
	fi
}

# install service files

function install_service {

	SERVICE="/etc/systemd/system"
	eo D "Writing service files to $SERVICE."
	# gridcoinmain.timer/delay
	echo "[Unit]" > $SERVICE/gridcoinmain.timer
	echo "Description=Runs gridcoin main chart scrape service timer" >> $SERVICE/gridcoinmain.timer
	echo "" >> $SERVICE/gridcoinmain.timer
	echo "[Timer]" >> $SERVICE/gridcoinmain.timer
	echo "OnUnitActiveSec=$GETINFOTIMER" >> $SERVICE/gridcoinmain.timer
	echo "OnBootSec=$GETINFODELAY" >> $SERVICE/gridcoinmain.timer
	echo "" >> $SERVICE/gridcoinmain.timer
	echo "[Install]" >> $SERVICE/gridcoinmain.timer
	echo "WantedBy=multi-user.target" >> $SERVICE/gridcoinmain.timer
	echo "[Unit]" > $SERVICE/gridcoinmain.service
	echo "Description=Run the collection script for the gridcoin main chart scrape" >> $SERVICE/gridcoinmain.service
	echo "After=netdata.service" >> $SERVICE/gridcoinmain.service
	echo "" >> $SERVICE/gridcoinmain.service
	echo "[Service]" >> $SERVICE/gridcoinmain.service
	echo "Type=oneshot" >> $SERVICE/gridcoinmain.service
	echo "User=$GRCUSER" >> $SERVICE/gridcoinmain.service
	echo "ExecStart=/bin/bash /usr/local/bin/gridcoinmain.sh" >> $SERVICE/gridcoinmain.service
	# gridcoinmarket.timer/delay
        echo "[Unit]" > $SERVICE/gridcoinmarket.timer
        echo "Description=Runs gridcoin market chart scrape service timer" >> $SERVICE/gridcoinmarket.timer
        echo "" >> $SERVICE/gridcoinmarket.timer
        echo "[Timer]" >> $SERVICE/gridcoinmarket.timer
        echo "OnUnitActiveSec=$GETMARKETTIMER" >> $SERVICE/gridcoinmarket.timer
        echo "OnBootSec=$GETMARKETDELAY" >> $SERVICE/gridcoinmarket.timer
        echo "" >> $SERVICE/gridcoinmarket.timer
        echo "[Install]" >> $SERVICE/gridcoinmarket.timer
        echo "WantedBy=multi-user.target" >> $SERVICE/gridcoinmarket.timer
        echo "[Unit]" > $SERVICE/gridcoinmarket.service
        echo "Description=Run the collection script for the gridcoin market chart scrape" >> $SERVICE/gridcoinmarket.service
        echo "After=netdata.service" >> $SERVICE/gridcoinmarket.service
        echo "" >> $SERVICE/gridcoinmarket.service
        echo "[Service]" >> $SERVICE/gridcoinmarket.service
        echo "Type=oneshot" >> $SERVICE/gridcoinmarket.service
        echo "User=$GRCUSER" >> $SERVICE/gridcoinmarket.service
        echo "ExecStart=/bin/bash /usr/local/bin/gridcoinmarket.sh" >> $SERVICE/gridcoinmarket.service
	# gridcoingeo.timer/delay
        echo "[Unit]" > $SERVICE/gridcoingeo.timer
        echo "Description=Runs gridcoin geography chart scrape service timer" >> $SERVICE/gridcoingeo.timer
        echo "" >> $SERVICE/gridcoingeo.timer
        echo "[Timer]" >> $SERVICE/gridcoingeo.timer
        echo "OnUnitActiveSec=$GETGEOTIMER" >> $SERVICE/gridcoingeo.timer
        echo "OnBootSec=$GETGEODELAY" >> $SERVICE/gridcoingeo.timer
        echo "" >> $SERVICE/gridcoingeo.timer
        echo "[Install]" >> $SERVICE/gridcoingeo.timer
        echo "WantedBy=multi-user.target" >> $SERVICE/gridcoingeo.timer
        echo "[Unit]" > $SERVICE/gridcoingeo.service
        echo "Description=Run the collection script for the gridcoin geography chart scrape" >> $SERVICE/gridcoingeo.service
        echo "After=netdata.service" >> $SERVICE/gridcoingeo.service
        echo "" >> $SERVICE/gridcoingeo.service
        echo "[Service]" >> $SERVICE/gridcoingeo.service
        echo "Type=oneshot" >> $SERVICE/gridcoingeo.service
        echo "User=$GRCUSER" >> $SERVICE/gridcoingeo.service
        echo "ExecStart=/bin/bash /usr/local/bin/gridcoingeo.sh" >> $SERVICE/gridcoingeo.service
	crontabinput=$(crontab -l -u $GRCUSER)
	newline=$'\n'
	skipcrontab="0"
        while read -r crontabread; do
		if [[ "$crontabread" == *"freegeoip"* ]]
		then
			skipcrontab="1"
			break
		else
			continue
		fi
	done <<< $crontabinput
	if [[ "$skipcrontab" == "1" ]]
	then
		eo Y "Does crontab entry exist for freegeoip?"
                eo W "Existing contrab entry for $GRCUSER for freegeoip."
                eo W "Will not write new entry however if you've changed what port to use for freegeoip please edit crontab for user $GRCUSER"
                eo D "Skipping entry. Use crontab -u $GRCUSER -e to edit users crontab"
	else
		eo N "Does crontab entry exist for freegeoip?"
		crontabnew="@reboot /usr/local/bin/freegeoip -http 127.0.0.1:$FREEGEOIPPORT -silent  >/dev/null 2>&1 &"
		crontaboutput="$crontabinput$newline$crontabnew"
		echo "$crontaboutput" | crontab -u $GRCUSER -
	fi
	eo D "Done."
	return 1
}

# function enable services and crontab with permission

function startup {

	eo D "Enabling services."
        systemctl enable gridcoinmain.timer >> setup.log 2>> setup.err
        systemctl enable gridcoinmarket.timer >> setup.log 2>> setup.err
        systemctl enable gridcoingeo.timer >> setup.log 2>> setup.err
	systemctl daemon-reload  >> setup.log 2>> setup.err
	eo D "Done."
	eo I "We need to startup freegeoip and services related to GRC-Netdata."
	ei 1 startup "May I start up these? (Y/N):"
	case "$startup" in
		Y|y ) startupcase="Y";;
		N|n ) startupcase="N";;
	esac
	if [[ "$startupcase" == "Y" ]]
	then
		eo D "freegeoip will run with sudo -u $GRCUSER this time however will run under $GRCUSER crontab after reboot automatically."
		sudo -u $GRCUSER /usr/local/bin/freegeoip -http 127.0.0.1:$FREEGEOIPPORT -silent >/dev/null 2>&1 &
		systemctl start gridcoinmain.timer
		systemctl start gridcoinmarket.timer
		systemctl start gridcoingeo.timer
	elif [[ "$startupcase" == "N" ]]
	then
		eo W "Not starting services please check readme.md about how to start services and freegeoip."
	else
		eo E "Bad input. read readme.md about manually starting."
		return 1
	fi
	ei 1 restart "We need to restart netdata to load new charts. May I? (Y/N):"
	case "$restart" in
		Y|y ) restartcase="Y";;
		N|n ) restartcase="N";;
	esac
	if [[ "$restartcase" == "Y" ]]
	then
		eo D "Restart netdata service."
		systemctl stop netdata.service >> setup.log 2>> setup.err
		systemctl start netdata.service >> setup.log 2>> setup.err
	elif [[ "$restartcase" == "N" ]]
	then
		eo D "Read readme.md about restarting netdata."
	else
		eo E "Bad input. read readme.md about manually restarting."
		return 1
	fi
	return 1
}


# Start here

echo
echo
eo D "Welcome to GRC-Netdata installation."
eo D
eo D "Running preinstall checks."
eo D
check_root
check_release
gather_info
check_dep
install_charts
install_scripts
install_freegeoip
install_service
startup
eo D "Setup is complete."
exit 1
