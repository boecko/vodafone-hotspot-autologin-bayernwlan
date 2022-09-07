#!/usr/bin/env bash
# captive portal auto-login script for Vodafone Hotspot
# Copyright (c) 2021 Sven Grunewaldt (strayer@olle-orks.org)
# Copyright (c) 2022 Jacob Ludvigsen (jacob@strandmoa.no)
# This is free software, licensed under the GNU General Public License v3.

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -euo pipefail

trm_useragent="Mozilla/5.0 (Linux x86_64; rv:95.0) Gecko/20100101 Firefox/95.0"
trm_maxwait="5000"

# Pings quadnine dns server (privacy respecting). Returns "online" if connected to network and offline otherwise
if ping -q -c1 9.9.9.9 &>/dev/null; then
    network_status=online
else
   network_status=offline
fi

# Reconnect if offline
if [ "$network_status" = "offline" ]; then

  # get session id
  SESSION_ID=$(curl https://hotspot.vodafone.de/api/v4/session \
  --user-agent "${trm_useragent}" --silent \
  --connect-timeout "${trm_maxwait}" | jq -r '.session')

  # login to business_premium profile
  RESULT=$(curl -H 'Content-Type: application/json' \
  --user-agent "${trm_useragent}" --connect-timeout "${trm_maxwait}" \
  --request POST --data "{\"loginProfile\": 6, \"accessType\": \"termsOnly\", \"session\": \"${SESSION_ID}\"}"\
  https://hotspot.vodafone.de/api/v4/login 2>/dev/null | jq -r '.message')

  if [ "$RESULT" = "OK" ]; then
    exit 0
    echo success!
  else
    echo "$RESULT"
    exit 1
  fi
fi
