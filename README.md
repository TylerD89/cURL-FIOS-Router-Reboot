-- PROJECT DESCRIPTION --

Unfortunately, Verizon went with a full-on lockdown approach with their newer routers, and removed the standard telnet functionality. This has completely taken away our ability to automate a reboot, as the new SSH replacement is ridiculously under-equipped.

I went on a 5-hour hunt for a way to completely automate a router reboot from a Linux box... while this way is very messy, I think this approach Is the only feasible one to date. I have tested this on the current firmware: 01.04.00.10-FTR and suspect that it should work for quite awhile.

Thanks to Anon4f653 for a great starting point! https://www.dslreports.com/forum/r32302610-G1100-Router-can-it-be-rebooted-via-an-SSH-command

-- HOW TO USE --

Clone / copy this bash script to your Linux/macOS machine (This script relies on curl, will not work on Windows unless modified)

Open terminal (varies depending on which Distribution / OS you are using)

Make the bash script executable (e.g: sudo chmod +x VerizonAutoReboot.sh)

Open the script with your preferred text editor (nano is easiest)

Replace the IP address under the "HOST=" variable, do the same with your "PASSWORD="

Run the script! Enjoy :)
