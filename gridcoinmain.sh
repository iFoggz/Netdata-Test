#!/bin/sh

if pgrep "gridcoin" > /dev/null
then
        GRCCONF='/usr/local/bin/grc-netdata.conf'
        # Read an config ini file for GRCPATH:)
        while read -r GRCCONFDATA; do
                if [[ ${GRCCONFDATA%%=*} == "GRCPATH" ]]
                then
                        GRCPATH=${GRCCONFDATA#*=}
                elif [[ ${GRCCONFDATA%%=*} == "GRCAPP" ]]
                then
                        GRCAPP=${GRCCONFDATA#*=}
                else
                        continue
                fi
        done < $GRCCONF
        "$GRCAPP" getinfo > "$GRCPATH"/getinfo.tmp && mv -f "$GRCPATH"/getinfo.tmp "$GRCPATH"/getinfo.json
        "$GRCAPP" getstakinginfo > "$GRCPATH"/getstakinginfo.tmp && mv -f "$GRCPATH"/getstakinginfo.tmp "$GRCPATH"/getstakinginfo.json
    else
    exit 1
fi
