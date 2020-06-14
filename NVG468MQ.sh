#!/bin/bash

# THIS IS THE REBOOT SCRIPT FOR THE FIOS NVG468MQ ROUTER

# User vars
HOST=
USERNAME=
PASSWORD=

# Since the router tracks information through IP address and the pages being sent to the configuration device, we need to send a GET request to
# the router every time we want to send a command.

# This function will help with the repetitive code. It takes a URL, sends a GET request to the router, and spits out the 'nonce' value required for tracking
getRequest() {
   # Make a GET request and store the plaintext output
   GET=`curl -k -s -H "Content-Type: application/json" http://${HOST}/$1` > /dev/null

   # Extract the given 'nonce' (48 digits) if in requested page
   RAW_NONCE=`echo "${GET}" | grep -o -P 'nonce" value=".{0,48}' | head -1`
   NONCE=`echo "${RAW_NONCE:13}" | tr -dc '[:alnum:]\n\r'`
}

postRequest() {
   POST=`curl -s http://${HOST}/$1 -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'Accept-Language: en-US,en;q=0.9' $2` > /dev/null
}

### AUTHENTICATION BLOCK ###

# Router needs to see we want to login, and we need a nonce value for it
getRequest "cgi-bin/login.ha"

# Send credinentals to router using the url-encoded HTML form with extracted nonce value
postRequest "cgi-bin/login.ha" "--data nonce=${NONCE}&username=${USERNAME}&password=${PASSWORD}&Continue=Continue --compressed --insecure"
sleep 2 # Router cooldown

### END OF AUTHENTICATION BLOCK ###

# Tell router we want to reboot, and get a nonce for it
getRequest "cgi-bin/restart.ha"

# With the nonce recieved, request reboot
postRequest "cgi-bin/restart.ha" "--data nonce=${NONCE}&Restart=Reboot+Gateway --compressed --insecure"

# Router will not start the reboot until we request a GET request for the reboot status page (just like a real browser would)
getRequest "cgi-bin/restarting.ha"
