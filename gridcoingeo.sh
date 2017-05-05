#!/bin/sh

#--------------------------------------------------
# This script intended to run as service addition to gridcoin_netdata or as a seperate service if more charts are added
#
# Will leave option of using online API (15000 requests per hour max (15000 / 60 = 250 per minute))
# Online API: https://freegeoip.net/json/1.1.1.1
# Took 30 seconds to figure out the 60 ips through web API
# Default setup with local API method which i've setup to port 5000 in service http://127.0.0.1:5000/json/1.1.1.1
# freegeoip requires freegeoip.license to be included with release when using binary. No complaints here.
#
# Locally Requires Dependencies
# jq
# freegeoip binary (included in service install)
#
# READ enviroment variables from config

GRCCONF='/usr/local/bin/grc-netdata.conf'
GRCGEO='/usr/local/bin/geo.json'
FREEGEOIPPORT=$(jq -r '.[].FREEGEOIPORT' $GRCCONF)
APIADDRESS="http://127.0.0.1:$FREEGEOIPPORT/json"
GRCAPP=$(jq -r '.[].GRCAPP' $GRCCONF)
GRCPATH=$(jq -r '.[].GRCPATH' $GRCCONF)

# END enviroment variables

if pgrep "gridcoin" > /dev/null
then

	peerinfo=$($GRCAPP getpeerinfo | jq -r '.[].addr' | rev | cut -d':' -f2- | rev)
	contNA=0	# North America
	contSA=0	# South America
	contEU=0	# Europe
	contAF=0	# Africe
	contAS=0	# Asia
	contOC=0	# Australia (Oceania)
	# contAN=0	# Antarctica // Removed as antarctica has no decent internet to support an application such as gridcoin. In event of one add to contOT.
	contOT=0	# Other, yes they exist 
	# Do loop to run through peerinfo string line by line.
	while read -r line; do
		# Curl each ip address wheather IPV4 or Ipv6 through API
		curldata=$(curl -s $APIADDRESS/$line | jq -r '.country_code')
		# Cross reference country_code to geo.json to return continent and increase value by one
		curlcont=$(jq -r '.[].'"$curldata" $GRCGEO)
		if [[ $curlcont == "NA" ]]
		then
			contNA=$(($contNA + 1))
		fi
		if [[ $curlcont == "SA" ]]
		then
			contSA=$(($contSA + 1))
		fi
		if [[ $curlcont == "EU" ]]
		then
			contEU=$(($contEU + 1))
		fi
		if [[ $curlcont == "AF" ]]
		then
			contAF=$(($contAF + 1))
		fi
		if [[ $curlcont == "AS" ]]
		then
			contAS=$(($contAS + 1))
		fi
		if [[ $curlcont == "OC" ]]
		then
			contOC=$(($contOC + 1))
		fi
		if [[ $curlcont == "AN" ]]
		then
			contAN=$(($contOT + 1))
		fi
		if [[ $curlcont == "XX" ]]
		then
			contOT=$(($contOT + 1))
		fi
		#No reply
		if [[ $curlcont == "" ]]
		then
			contOT=$(($contOT + 1))
		fi
	done <<< "$peerinfo"
	# take data and make temporary json file with results
	echo "[{" > $GRCPATH/geooutput.tmp
	echo '"contNA"': '"'$contNA'",' >> $GRCPATH/geooutput.tmp
	echo '"contSA"': '"'$contSA'",' >> $GRCPATH/geooutput.tmp
	echo '"contEU"': '"'$contEU'",' >> $GRCPATH/geooutput.tmp
	echo '"contAF"': '"'$contAF'",' >> $GRCPATH/geooutput.tmp
	echo '"contAS"': '"'$contAS'",' >> $GRCPATH/geooutput.tmp
	echo '"contOC"': '"'$contOC'",' >> $GRCPATH/geooutput.tmp
	echo '"contOT"': '"'$contOT'"' >> $GRCPATH/geooutput.tmp
	echo "}]" >> $GRCPATH/geooutput.tmp
	# Finally move data to geooutput.tmp
	mv -f $GRCPATH/geooutput.tmp $GRCPATH/geooutput.json
	else
	exit 1
fi
