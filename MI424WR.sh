#!/bin/bash

# THIS IS THE REBOOT SCRIPT FOR THE FIOS MI424WR ROUTER

# User-defined vars
HOST=
USERNAME=
PASSWORD=

### AUTHENTICATION BLOCK ###
  # We need three values from the router, a SessionID, SessionKey, and an AuthKey.
  # Since this router's web interface is heavy in JavaScript, we need to pay attention to the HTML Forms in the POST requests to reverse-engineer the web commands

# A FEW THINGS TO NOTE:
  # 'passwordmask_' is the name of the password input box on the login page. It will always have a suffix including the SessionID (e.g. passwordmask_1234567890)
  # The router produces 1 AuthKey for every SessionID. The AuthKey acts as a password salt. (SaltedPass = Password+ AuthKey)
  # Format for an HTML form item: key = value (e.g "auth_key" = "123456789")
  # The login page ID is '9073'. On a successful authentication, the router will send a 302 request with ID of the home page; which is '9130'. Page ID '9070' means there are already a maximum amount of router session

# Make a GET request and store the plaintext output
GET=`curl -k -s -H "Content-Type: application/json" http://${HOST}/index.cgi` > /dev/null

# Extract the given SessionID (9 or 10 digits)
RAW_SESSION_ID=`echo "${GET}" | grep -o -P 'passwordmask_.{0,10}' | head -1`     # Find the form key and extract +10 characters after match
SESSION_ID=`echo "${RAW_SESSION_ID:13}" | tr -dc '[:alnum:]\n\r'`      # Extract the actual SessionID integer value

# Extract the given AuthKey (9 or 10 digits)
AUTH_KEY=`echo "${GET}" | grep -oP '"auth_key" value="\K[^"]+'`      # Find the AuthKey value

# Extract and encode SessionKey (15 digits)
SESSION_KEY=`echo "${GET}" | grep -oP '"session_key" value="\K[^"]+' | sed 's/&lt;/</g' | sed 's/&gt;/>/g'` # Find the SessionKey value

# Construct MD5 Hash (This is done automatically by the router with JavaScript. We need to do this manually)
SALTED="${PASSWORD}""${AUTH_KEY}"     # Concatenate Password and AuthKey to form the salted password
MD5_HASH=`echo -n "${SALTED}" | md5sum | cut -c1-32`     # Use md5sum to convert the salted password into the md5 password hash

sleep 1 # Router cooldown

# Send credinentals to router using the url-encoded HTML form
POST=`curl -s 'http://192.168.1.2/index.cgi' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'Accept_Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9' -H "Cookie: rg_cookie_session_id=${SESSION_ID}" --data "active_page=9073&session_key=${SESSION_KEY}&active_page_str=page_login&page_title=Login&mimic_button_field=submit_button_login_submit%3A+..&button_value=.&strip_page_top=0&user_name_defval=&user_name=${USERNAME}&passwordmask_${SESSION_ID}=&md5_pass=${MD5_HASH}&auth_key=${AUTH_KEY}"` > /dev/null

if echo "${POST}" | grep -q -o "page=9130" # If router redirects us to the home page
then
	echo "Authentication Successful" # Success
else
	if echo "${POST}" | grep -q -o "page=9070" # If router redicts us to 'too many sessions page'
	then
		echo "Authentication Error: Too many sessions open" # Error
	else # All other page numbers
		echo "Authentication Failed" # Error
	fi
fi

### END OF AUTHENTICATION BLOCK ###

# Reboot Command
sleep 1 # Router cooldown
POST=`curl -s 'http://192.168.1.2/index.cgi' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'Accept-Language: en-US,en;q=0.9' -H "Cookie: rg_cookie_session_id=${SESSION_ID}" --data "active_page=140&session_key=${SESSION_KEY}&active_page_str=page_reboot&page_title=Reboot+Router&mimic_button_field=submit_button_ro_submit%3A+..&button_value=140&strip_page_top=0"` > /dev/null

if echo "${POST}" | grep -q -o "page=850" # If router redirects us to the waiting page
then
        echo "Reboot Command Executed" # Success
else # All other page numbers
				echo "Something Went Wrong" # Error
fi
# End of reboot command

# Print values
echo "----------------------------"
echo "Session ID: ${SESSION_ID}"
echo "Session Key: ${SESSION_KEY}"
echo "Auth Key: ${AUTH_KEY}"
echo "Hash: ${MD5_HASH}"
echo ""
