#!/bin/bash

# Script to ask for the name of a teaching computer to remote access

# Author      : r.purves@arts.ac.uk
# Version 1.0 : 03-09-2013 - Initial Version
# Version 1.1 : 05-09-2013 - Detect if a file is present and use the address there

# Sadly this script runs as the admin management user
# and OS X prohibits GUI access from non-gui users, so we'll have to
# 1) Embed applescript to find computer name into the script
# 2) Run it as the currently logged in user. Casper supplies this on $3 so let's use it.

# Check to see if the override file is in place

if [ -f /Users/Shared/remote.txt ]
then

# Read out the contents of that file into a variable

	address=$( cat /Users/Shared/remote.txt )

# Open the screen sharing at the specified computer address

	open vnc://vnc:vnc@$address

# Exit happy!

	exit 0
fi

# Override file doesn't exist. Ok, run the applescript menu to ask for computer name.

su $3 -c /usr/bin/osascript <<-EOF
	tell application "Finder" 
	set temp to display dialog "Enter the name of the computer to view: " default answer ""
	set text_user_entered to the text returned of temp
	set old_delimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {","}
	set variable1 to the first text item of text_user_entered
	do shell script "open vnc://vnc:vnc@" & variable1 & "/"
	end tell
EOF

exit 0
