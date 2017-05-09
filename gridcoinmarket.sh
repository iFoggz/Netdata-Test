#!/bin/bash
# Scraping the market stats for Gridcoin
# For service use only

if pgrep "gridcoin" > /dev/null
then
	GRCCONF='/usr/local/bin/grc-netdata.conf'
        GRCCONF='/usr/local/bin/grc-netdata.conf'
        # Read an config ini file for GRCPATH:)
        while read -r GRCCONFDATA; do
                if [[ ${GRCCONFDATA%%=*} == "GRCPATH" ]]
                then
                        GRCPATH=${GRCCONFDATA#*=}
                else
                        continue
                fi
        done < $GRCCONF
        curl "https://api.coinmarketcap.com/v1/ticker/gridcoin/" > $GRCPATH/gridcoin_cmc.tmp && mv -f $GRCPATH/gridcoin_cmc.tmp $GRCPATH/gridcoin_cmc.json
	else
	exit 1
fi
