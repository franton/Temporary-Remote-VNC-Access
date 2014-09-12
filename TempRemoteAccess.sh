#!/bin/bash

# Script to enable/disable student vnc access account

# Author      : contact@richard-purves.com
# Version 1.0 : 03-09-2013 - Initial Version

# Check to see if parameter is present. Fail if not.

if [ "$4" == "" ] ; then
	echo "Error: Missing parameter. e.g. enable"
	exit 1
fi

# Depending on passed parameter, execute the appropriate commands.

case $4 in

	enable)

# Create a non admin level VNC account with no home folder. This will stop virtual desktop working.
	
		jamf createAccount -username vnc -realname vnc -password vnc -hiddenUser

# Enable remote viewing for the newly created user account
	
		/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
		-activate \
		-configure -users vnc \
		-access -on \
		-privs -ControlObserve -ShowObserve -ObserveOnly \
		-clientopts -setmenuextra -menuextra yes  \
		-setreqperm -reqperm no \
		-restart -agent -menu -console

	;;

	disable)
	
# Force logout the VNC account. Horrible horrible hack to do this that i'm not proud of.
# Get the loginwindow process pid for VNC user

VNCPID=$( ps -Ajc | grep loginwindow | grep vnc | awk '{print $2}' )

# No Mr. VNC account ... we expect you to log out!

sudo kill -9 $VNCPID

# Delete the vnc account as the lesson is probably finished now

		jamf deleteAccount -username vnc -deleteHomeDirectory

# For safety, set the remote viewing settings back to UAL default
		
		/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
		-activate \
		-configure -users uadmin \
		-access -on \
		-privs -all \
		-clientopts -setmenuextra -menuextra yes  \
		-setreqperm -reqperm no \
		-restart -agent -menu -console

	;;
	
	*)

# Oopsy, you made a mistake in Casper Policy. This should report the mistake in the logs.
	
		echo "Error: Incorrect parameter set: "$4
		exit 1
		
	;;

esac

# All done! Exit gracefully.

exit 0
