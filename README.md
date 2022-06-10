# Vodafone Hotspot Captive Portal Auto-login (@BayernWlan specifically)

This a is a script used to automatically login into the Vodafone Hotspot captive portal used by @bayernWlan.
Its intended use is ensuring headless (i.e. without display screen) linux devices necessary for study and research stay connected to the internet.

## Requirements
This script uses tools commonly preinstalled on Unix-based operating systems. Some formatting may be necessary to run on a different shell than bash.

## Usage
First make it non-writable for security

`$ chmod 555 net-login.sh`

move this script to /usr/bin/

`$ sudo mv net-login.sh /usr/bin/`

Setup a cron job to run this script at reboot and every 10 minutes. In this example I use crontab for Raspberry Pi.

`$ crontab -e`
```
#Check internet connection and reconnect if necessary at boot and every 10 minutes
*/10 * * * * net-login.sh
@reboot sleep 120 && /usr/bin/net-login.sh &
```

