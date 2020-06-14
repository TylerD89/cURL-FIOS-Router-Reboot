#!/bin/bash

# THIS IS THE REBOOT SCRIPT FOR THE G1100 FIOS ROUTER

# User-defined vars
HOST=
PASSWORD=


# Receive password salt from Router and create hash
SALT=`curl -s -k -H "Content-Type: application/json" http://${HOST}/api/login | sed 's/^.*passwordSalt":"\([a-z0-9-]*\)".*$/\1/'`
HASH=`/bin/echo -n "$PASSWORD$SALT" | sha512sum  | awk '{print $1}'`

# Send password hash to router
POST=`curl -s -k -c cookie.txt -H "Content-Type: application/json" -X POST -d "{\"password\":\"$HASH\"}" http://${HOST}/api/login`

if echo "${POST}" | grep -q -o "\"error\""
then
     echo "Authentication Failed"
else
     echo "Authentication Successful"
fi


# Extract SessionID and AuthToken from the recieved cookie
TOKEN=`awk '/XSRF-TOKEN/ {print $NF}' cookie.txt`
SESSION=`awk '/Session/ {print $NF}' cookie.txt`

# Cooldown
sleep 2

# Send a POST method with Authentication (This is the actual reboot command)
POST=`curl -s http://${HOST}/api/settings/reboot -X POST -H 'Connection: keep-alive' -H 'Content-Length: 0' -H 'Accept: application/json, text/plain, */*' -H "X-XSRF-TOKEN: $TOKEN" -H 'Accept-Language: en-US,en;q=0.9' -H "Cookie: test; Session=$SESSION; XSRF-TOKEN=$TOKEN"`

if echo "${POST}" | grep -q -o "\"error\""
then
     echo "Something Went Wrong"
else
     echo "Reboot Command Executed"
fi

echo "------------------------"
echo "XSRF-Token: ${TOKEN}"
echo "Session ID: ${SESSION}"
echo "Hash: ${HASH}"
echo ""

# Cleanup files
sleep 4
rm cookie.txt
