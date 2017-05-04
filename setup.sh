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
GRCCONF='/usr/local/bin/grc-netdata.conf'
BINFOLDER='/usr/local/bin'
STD='1> /dev/null 2> setup.err'
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
	checkroot=$(id | cut -d "=" -f2- | rev | cut -d "(" -f4-)
	if [[ "$checkroot" == "0" ]]
	then
		eo I "DETECTED: UID=0 (root)"
		eo Y "Do we have root privilege?"
		return 1
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
	exit 1

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

echo 

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
		exit 1
	fi
	if [[ -a /usr/sbin/netdata ]]
	then
		eo Y "Is netdata installed?"
	fi
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
			rm -f "GRCCONF" "$STD"
			return 1
		else
			eo E "Bad input. Try again."
			conf_exists
			return 1
		fi
	else
		eo N "Does $GRCONF already exist?"
		return 1
	fi
}

# Gather config

function conf_gather {

	eo D
        eo D "Lets gather information about your custom setup."
        eo I "If you leave the value empty the default option will be selected."
        eo W "Not all values are verified at this time so carefully enter the correct values."
	eo D
	ei conf
}

function conf_commit {

	echo

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

# Preinstall checks.

check_root
check_release
check_dep
gather_info
