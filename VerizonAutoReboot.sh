#!/bin/bash
# Created by TylerD89
# March 28, 2020

# User-defined vars
HOST=192.168.1.1
PASSWORD=Your_Password


# Receive password salt from Router
SALT=`curl -k -H "Content-Type: application/json" http://${HOST}/api/login | sed 's/^.*passwordSalt":"\([a-z0-9-]*\)".*$/\1/'`
digest=`/bin/echo -n "$PASSWORD$SALT" | sha512sum  | awk '{print $1}'`

# Salt the password, POST to the router, and save the cookie
curl -k -c cookie.txt -H "Content-Type: application/json" -X POST -d "{\"password\":\"$digest\"}" http://${HOST}/api/login

# Extract the given SessionID and AuthToken from the recieved cookie
TOKEN=`awk '/XSRF-TOKEN/ {print $NF}' cookie.txt`
SESSION=`awk '/Session/ {print $NF}' cookie.txt`

# Router cooldown
sleep 2

# The main reboot command. Using a specific format, this POST request sends our AuthToken and SessionID to the reboot script
curl http://${HOST}/api/settings/reboot -X POST -H 'Connection: keep-alive' -H 'Content-Length: 0' -H 'Accept: application/json, text/plain, */*' -H "X-XSRF-TOKEN: $TOKEN" -H 'Accept-Language: en-US,en;q=0.9' -H "Cookie: test; Session=$SESSION; XSRF-TOKEN=$TOKEN"

# NOTE: You can experiment with the above command by changing the /api/settings/reboot script to any script on the router. 
#     You would just have to figure out what the script is called

# Cleanup files
sleep 3 # Put a sleep timer on this, because I figured out that the cookie was beig removed before the cURL command could execute
rm cookie.txt
