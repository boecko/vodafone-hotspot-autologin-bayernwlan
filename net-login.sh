#!/bin/sh
# captive portal auto-login script for Vodafone Hotspot
# Copyright (c) 2021 Sven Grunewaldt (strayer@olle-orks.org)
# Copyright (c) 2022 Jacob Ludvigsen (jacob@strandmoa.no)
# This is free software, licensed under the GNU General Public License v3.

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
set -euo pipefail

trm_useragent="Mozilla/5.0 (Linux x86_64; rv:95.0) Gecko/20100101 Firefox/95.0"
trm_maxwait="5000"
trm_neededprofile="6"
trm_vodafonedns="10.175.177.132"
SESSIONFILE=/tmp/bayernhotspot.session

# Pings vodafone private dns server - if this fails, we are not in a vodafone network
if ping -q -c1 ${trm_vodafonedns}  &>/dev/null; then
    hotspot_avail=true
else
   hotspot_avail=false
fi


# Reconnect if offline
if [ "$hotspot_avail" = "true" ]; then

  # get session id
  curl https://hotspot.vodafone.de/api/v4/session \
       --user-agent "${trm_useragent}" --silent \
       --connect-timeout "${trm_maxwait}" > $SESSIONFILE

  SESSION_ID=$(jq -r '.session' $SESSIONFILE)
  SESSION_PROFILE=$(jq -r '.currentLoginProfile' $SESSIONFILE)

  echo "Session-ID: $SESSION_ID"
  if [ "$SESSION_PROFILE" = "$trm_neededprofile" ]; then
      # already logged in
      exit 0
  fi
  # login to business_premium profile
  RESULT=$(curl -H 'Content-Type: application/json' \
  --user-agent "${trm_useragent}" --connect-timeout "${trm_maxwait}" \
  --request POST --data "{\"loginProfile\": $trm_neededprofile, \"accessType\": \"termsOnly\", \"session\": \"${SESSION_ID}\"}"\
  https://hotspot.vodafone.de/api/v4/login 2>/dev/null | jq -r '.message')

  if [ "$RESULT" = "OK" ]; then
    exit 0
    echo success!
  else
    echo "$RESULT"
    exit 1
  fi
fi

