#!/bin/bash

# User-defined vars
HOST=192.168.1.1
PASSWORD=Your_Password


# Receive SALT from Router
SALT=`curl -k -H "Content-Type: application/json" http://${HOST}/api/login | sed 's/^.*passwordSalt":"\([a-z0-9-]*\)".*$/\1/'`
digest=`/bin/echo -n "$PASSWORD$SALT" | sha512sum  | awk '{print $1}'`

# Send Password to login with the SALT appended
curl -k -c cookie.txt -H "Content-Type: application/json" -X POST -d "{\"password\":\"$digest\"}" http://${HOST}/api/login

# Extract SessionID and AuthToken from the recievedcookie
TOKEN=`awk '/XSRF-TOKEN/ {print $NF}' cookie.txt`
SESSION=`awk '/Session/ {print $NF}' cookie.txt`

# Cooldown
sleep 2

# Send a POST method with Authentication (This is the actual reboot command)
curl http://${HOST}/api/settings/reboot -X POST -H 'Connection: keep-alive' -H 'Content-Length: 0' -H 'Accept: application/json, text/plain, */*' -H "X-XSRF-TOKEN: $TOKEN" -H 'Accept-Language: en-US,en;q=0.9' -H "Cookie: test; Session=$SESSION; XSRF-TOKEN=$TOKEN"

# Cleanup files
sleep 4
rm cookie.txt
