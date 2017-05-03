#!/bin/sh

if pgrep "gridcoin" > /dev/null
then
        GRCCONF='/usr/local/bin/grc-netdata.conf'
        GRCAPP=$(jq -r '.[].GRCAPP' $GRCCONF)
        GRCPATH=$(jq -r '.[].GRCPATH' $GRCCONF)
        "$GRCAPP" getinfo > "$GRCPATH"/getinfo.tmp && mv -f "$GRCPATH"/getinfo.tmp "$GRCPATH"/getinfo.json
        "$GRCAPP" getstakinginfo > "$GRCPATH"/getstakinginfo.tmp && mv -f "$GRCPATH"/getstakinginfo.tmp "$GRCPATH"/getstakinginfo.json
    else
    exit 1
fi
