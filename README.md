# GRC-Netdata
* Netdata charts for gridcoin

# Tested on
* Ubuntu/Debian install Install Passes XD. Debian should be the same but feel free to test.
* Fedora passed but only tested on one version of Fedora.

# Needs testing on.
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
* The testing needs to be done as all i've done is look up packages and what installers those releases use! Its blind! 
