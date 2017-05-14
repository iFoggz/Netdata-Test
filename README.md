# GRC-Netdata
* Netdata charts for gridcoin

# Tested on
* Ubuntu/Debian install Install Passes

# Needs testing on.
* Fedora
* Arch
* openSUSE

# Get started.
* chmod +x setup.sh
* ./setup.sh

# Prereqs
* [Netdata](https://github.com/firehol/netdata/wiki/Installation)
* Gridcoin Daemon gridcoinresearchd

# Notes
* All required dependencies the scripts will use will be autoinstalled
* Exception is crontab and systemd as I'm not ready to touch that one yet. Too vague of information across platform.
* If you like to see all deminsons even if they are 0 which netdata hides goto Settings on netdata site and under "What dimensions to show" click it to say all instead of non zero.
