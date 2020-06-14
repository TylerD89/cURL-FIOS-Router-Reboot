-- PROJECT DESCRIPTION / WHAT THESE DO--

Unfortunately, Verizon, Frontier (and now Ziply), have went with a full-on lockdown approach with their newer FIOS routers and removed the standard telnet functionality. This has completely taken away our ability to automate a reboot, as the new SSH replacement is ridiculously under-equipped.

I went ahead and reversed engineered the web reboot on most of the FIOS routers, including the G1100, NVG468MQ, and MI424WR (some firmwares do not include telnet in their firmware). These are the only routers I have ever been issued from Frontier and Ziply, so my apologies if yours is not covered in this respository.

Thanks to Anon4f653 for a great starting point for the G1100 Script! https://www.dslreports.com/forum/r32302610-G1100-Router-can-it-be-rebooted-via-an-SSH-command 

-- HOW TO USE --

1. Clone / copy these bash scripts to your Linux/macOS machine (This script relies on curl and bash, so it will not work on Windows unless modified)

2. Open up a terminal

3. Make the bash script executable (e.g: sudo chmod +x <script>.sh)

4. Open the script you need for your roter model with your preferred text editor (nano is easiest)

5. Replace the IP address under the "HOST=" variable with your router's IP, do the same with your "PASSWORD=", and "USERNAME=" (not present nor needed on the G1100 router script). 

6. Run the script for your router! Enjoy :)
