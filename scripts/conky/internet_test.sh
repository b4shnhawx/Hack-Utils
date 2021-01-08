#!/bin/bash

output=`ping -W 1 -c 1 8.8.8.8 | grep -o "1 received"`

if [[ $output == "1 received" ]];
then
	echo -e "Connected"
else
	echo -e  "Disconnected"
fi
