#!/bin/bash

#---------------- FORMATING VARIABLES -------------
#Here are some variable for the text format. These variables uses escape sequences $
#In linux the escape sequences are \e, \033, \x1B
BLINK="\e[5m"
BOLD="\e[1m"
UNDERLINED="\e[4m"
INVERT="\e[7m"
HIDE="\e[8m"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BLACK="\e[30m"
WHITE="\e[37m"
CYAN="\e[36m"
LIGHTYELLOW="\e[1;33m"

UNDERRED="\e[41m"
UNDERGREEN="\e[42m"
UNDERWHITE="\e[107m"
UNDERGRAY="\e[47m"
UNDERCYAN="\e[46m"
UNDERYELLOW="\e[103m"

#Obv we need a control sequence that closes the rest control sequences
END="\e[0m"

TAB="\t"


#---------------- VARIABLES -------------
#Version
version="0.4"
#All interfaces in used in the system
interfaces_extracted=`ip addr | grep ^[0-9]: | cut -f 2 -d ":" | sed 's/ //g' | tr '\n' " "`
#All OVPNS profiles used in the system in one column
ovpns_extracted=`ls --width=1 $HOME/.secret/ovpns/ | tr '\n' " "`
ovpns_active_extracted=`ps aux | grep openvpn | grep /root/.secret/ovpns/ | rev | cut -f1 -d "/" | rev | tr '\n' " "`

#Transforms the strings into arrays
read -a ifaces_array <<< $interfaces_extracted
read -a ovpns_array <<< $ovpns_extracted
read -a ovpns_active_array <<< $ovpns_active_extracted

programs_array=(ping nmcli traceroute telnet iftop iptraf-ng nethogs slurm tcptrack vnstat bwm-ng bmon ifstat speedometer openvpn nmap tshark sipcalc nload speedtest-cli lynx elinks macchanger kali-anonsurf(github) torctl)
bandwith_interface_programs_array=(slurm iftop speedometer tcptrack ifstat vnstat nload iptraf)
bandwith_programs_array=(vnstat bwm-ng)
web_terminals_array=(cat elinks lynx)

#Saves how many interfaces have the system
number_of_interfaces=${#ifaces_array[@]}
#Saves how many ovpns profiles have the system
number_of_ovpns=${#ovpns_array[@]}
#Saves how many ovpns active connections have the system
number_of_ovpns_active=${#ovpns_active_array[@]}
#Saves how many programs are used in this script
number_of_programs=${#programs_array[@]}
#Saves how many programs to monitor the traffic are used in this script
number_of_bandwith_interface_program=${#bandwith_interface_programs_array[@]}
number_of_bandwith_program=${#bandwith_programs_array[@]}
number_of_web_terminals=${#web_terminals_array[@]}

#---------------- FUNCTIONS ----------------
menu()
{
	clear

	echo -e $TAB$RED"  _   _      _                      _        _   _ _   _ _
	 | \\ | | ___| |___      _____  _ __| | __   | | | | |_(_) |___
	 |  \\| |/ _ \\ __\\ \\ /\\ / / _ \\| '__| |/ /   | | | | __| | / __|
	 | |\\  |  __/ |_ \\ V  V / (_) | |  |   <    | |_| | |_| | \\__ \\
	 |_| \\_|\\___|\\__| \\_/\\_/ \\___/|_|  |_|\\_\\    \\___/ \\__|_|_|___/		v $version
-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	"$END
	echo ""



	echo -e $BLUE"  >>> MISCELLANEOUS <<<  "$END
	echo ""

	echo -e $LIGHTYELLOW"   chckdep"$END")" "Check all the dependencies"	$TAB$TAB$LIGHTYELLOW"up"$END")" "Update Network Utils"
	echo -e $TAB$LIGHTYELLOW" 0"$END")" "Exit"$TAB$TAB
	echo ""
	echo ""



	echo -e $BLUE"  >>> BASICS <<<  "$END
	echo ""

	echo -e $TAB$LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"$TAB$TAB$LIGHTYELLOW"wc"$END")" "Connect to Wifi (nmcli)"
	echo -e $TAB$LIGHTYELLOW" 1"$END")" "Ping"$TAB$TAB				$TAB$TAB$LIGHTYELLOW" 2"$END")" "Try internet connection"	$TAB$TAB$LIGHTYELLOW" 3"$END")" "Traceroute"$TAB$TAB
	echo -e $TAB$LIGHTYELLOW" 4"$END")" "Whois"$TAB$TAB				$TAB$TAB$LIGHTYELLOW" 5"$END")" "Hops to gateway"$TAB 	 	$TAB$TAB$LIGHTYELLOW" 6"$END")" "ARP table"$TAB$TAB
	echo -e	$TAB$LIGHTYELLOW" 7"$END")" "Public IP"$TAB$TAB 		$TAB$TAB$LIGHTYELLOW" 8"$END")" "Traffic"$TAB$TABTAB$TAB	$TAB$TAB$LIGHTYELLOW" 9"$END")" "Traffic by interface"
	echo -e $TAB$LIGHTYELLOW"10"$END")" "Check remote port status" 	$TAB$TAB$LIGHTYELLOW"11"$END")" "Ports in use"$TAB  		$TAB$TAB$LIGHTYELLOW"12"$END")" "Search port info (online)"
	echo -e $TAB$LIGHTYELLOW"13"$END")" "Firewall rules (iptables)"	$TAB$TAB$LIGHTYELLOW"14"$END")" "Route table"$TAB$TAB   	$TAB$TAB$LIGHTYELLOW"15"$END")" "Check IP blacklist / abuse"
	echo -e $TAB$LIGHTYELLOW"16"$END")" "Speed test"				$TAB$TAB$TAB$TAB$LIGHTYELLOW"17"$END")" "Cyber threats search (online)"
	echo -e
	echo ""




	echo -e $BLUE"  >>> ADVANCED <<<  "$END
	echo ""

	echo -e $LIGHTYELLOW"     advif"$END")" "Advanced interfaces info"$TAB 	$TAB$LIGHTYELLOW" sniff"$END")" "Sniff packets"
	echo -e $LIGHTYELLOW"     pping"$END")" "Ping (personalized)"$TAB$TAB		$TAB$LIGHTYELLOW"     X"$END")" "Traceroute (personalized)"
	echo -e $LIGHTYELLOW"      ovpn"$END")" "Connect to a OVPN server" $TAB$TAB$LIGHTYELLOW"cliweb"$END")" "Web in CLI (elinks)"
	echo -e $LIGHTYELLOW"    macman"$END")" "MAC manufacturer"	$TAB$TAB$TAB$LIGHTYELLOW"  anon"$END")" "Anonymizer"
	echo ""
	echo ""

	echo "Type an option:"
	echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
	echo ""

#	if [[ $invalidoption == true ]];
#	then
#		echo "Wut? I guess this is not a valid option... :/"
#		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
#		echo ""
#
#	else
#		echo "Type an option:"
#		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
#		echo ""
#	fi


}

command_for_interfaces()
{
	echo -e "Available interfaces:"$BLUE ${ifaces_array[@]}
	echo ""

	for (( interface_number=0; interface_number<$number_of_interfaces; interface_number++ ));
	do
		echo -e $BLUE">>> "${ifaces_array[$interface_number]}" <<<"$END
		$1 ${ifaces_array[$interface_number]} $2
		echo ""
	done
}

options_selector()
{
	number=$1
	declare -n array=$2
	array=("Exit" "${array[@]}")

	echo -e "\nOPTIONS:"

	for (( whatever_number=1; whatever_number<=$1; whatever_number++ ));
	do
		echo -e " " $LIGHTYELLOW$whatever_number$END") "$BLUE${array[$whatever_number]}$END | sed ''/inactive/s//`printf "\033[31mdisabled\033[0m"`/'' | sed ''/active/s//`printf "\033[32menabled\033[0m"`/'' | sed ''/Disconnected/s//`printf "\033[31mdisconnected\033[0m"`/'' | sed ''/Connected/s//`printf "\033[32mconnected\033[0m"`/''
	done

	echo ""
	echo -e " " $LIGHTYELLOW"0"$END") "$BLUE${array[0]}$END
	echo ""
	echo "Type an option:"

	#Reset the array for no add every time the function is executed a element "Exit"
	unset array[0]

}

response_checker()
{
	selection=$1
	number_of_options=$2
	number_of_options=$((number_of_options + 1))

	while true;
	do
		if [ "$selection" == "0" ] || [ "$selection" == "n" ];
		then
			exit_selection=true
			invalidoption=true
			return

		elif [ $selection -lt $number_of_options ] || [ "$selection" == "y" ];
		then
			break

		else
			echo ""
			echo -e "Type a valid option:"
			echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
		fi
	done
}

ip_checker()
{
	ip_address=$1
	ip_address_format=`echo $ip_address | egrep "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" `

	while [ "$ip_address" != "$ip_address_format" ] || [ "$ip_address" == "" ];
	do
		echo -e "Please, type a valid IP:"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
		echo ""

		ip_address_format=`echo $ip_address | egrep "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" `
	done

	exit_selection=false
}

show_programs()
{
	echo -e $LIGHTYELLOW"chckdep"$END")" "Check all the dependencies"
	echo ""

	for (( program_number=0; program_number<$number_of_programs; program_number++ ));
	do
		path_actual_program=`which ${programs_array[$program_number]}`
		#program_name=${programs_array[$program_number]}

		if [[ $path_actual_program == '' ]];
		then
			printf "%-2s %-20s $UNDERRED$BLACK %-0s $END" "  >" "${programs_array[$program_number]}" "UNINSTALLED"
			echo ""
		else
			printf "%-2s %-20s $UNDERGREEN$BLACK %-1s $END %-1s %-1s" "  >" "${programs_array[$program_number]}" " INSTALLED " ">>>>>" $path_actual_program
			echo ""
		fi

		#program_name=""
		path_actual_program=""
	done
}

install_uninstall_programs_array()
{
	option=$3

	clear
	show_programs

	for (( program=0; program<$number_of_programs; program++ ));
	do
		path_actual_program=`which ${programs_array[$program]}`
		#program_name=${programs_array[$program_number]}

		echo ""
		echo "Checking ${programs_array[$program]} ..."
		sleep 0.1

		if [[ $path_actual_program == '' && $option == "id" ]];
		then
			echo "Installing ${programs_array[$program]} ..."
			echo ""

			#echo "sudo apt-get --assume-yes $1 ${programs_array[$program]} > /dev/null"
			sudo apt-get --assume-yes $1 $2 ${programs_array[$program]} &> /dev/null
			pacman -Sy --noconfirm ${programs_array[$program]} &> /dev/null

		elif [[ ${programs_array[$program]} == "nmcli" ]];
		then
			sudo apt-get --assume-yes install network-manager &> /dev/null
			pacman -Sy --noconfirm install network-manager &> /dev/null

		elif [[ $path_actual_program == "/"* && $option == "ud" && ${programs_array[$program]} == "ping" || ${programs_array[$program]} == "nmcli" || ${programs_array[$program]} == "traceroute" ]];
		then
			echo "Omiting ${programs_array[$program]} ..."
			sleep 0.5

		elif [[ $path_actual_program == "/"* && $option == "ud" ]];
		then
			echo "Unistalling ${programs_array[$program]} ..."
			echo ""

			sudo apt-get --assume-yes $1 $2 ${programs_array[$program]} &> /dev/null
			pacman -Rsn --noconfirm ${programs_array[$program]} &> /dev/null
		fi

		#program_name=""
		path_actual_program=""

		clear
		show_programs
	done
}

#()
#{
#	#Wait for user to press the enter key after he view what he need
#	echo ""
#	echo ""
#	echo -ne $UNDERGRAY$BLACK"Press ENTER to go back to the main menu"$END
#	tput civis
#	read
#  	tput cnorm
#}

#---------------- SCRIPT ----------------
while true;
do
	#Starts the main screen
	menu
	#When user select an option, sets the parameter for distinguise an invalid option in false
	invalidoption=false
	exit_selection=false

	clear

	while [[ $exit_selection == false ]];
	do
		case $option in
			chckdep)
				valid_option=false														####################################

				while [[ $valid_option == false ]];
				do
					show_programs

					echo ""
					echo ""

					echo -e " " $BLUE"id"$END")" "Install all the dependencies (before install, exit netutils and type apt-get update && apt-get upgrade)"
					echo -e " " $BLUE"ud"$END")" "Uninstall all the dependencies (except ping, nmcli and traceroute)"
					echo ""
					echo -e " " $BLUE" 0"$END")" "Cancel"
					echo ""
					echo ""

					echo "Type an option:"
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
					echo ""

					case $option in
						id)
							install_uninstall_programs_array "install" "" "$option"

							echo ""
							echo "If you have some problems installing some programs, enter --> apt-get install --fix-missing"

							valid_option=true

							;;
						ud)
							install_uninstall_programs_array "" "purge" "$option"

							valid_option=true

							;;
						0)
							valid_option=true

							;;
						*)
							clear

							;;
					esac

				done

				;;
			if)
				echo -e $LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"
				echo ""

				#Function		First part of the command	Second part of the command
				#command_for_interfaces "ifconfig "			""
				command_for_interfaces "ifconfig " ""

				;;

			wc)
				echo -e $LIGHTYELLOW"wc"$END")" "Connect to Wifi (nmcli)"
				echo ""

				nmcli device wifi rescan
				nmcli device wifi list
				echo ""

				echo -ne "SSID: "$LIGHTYELLOW ; read ssid ; echo -ne $END
				echo -ne "Password: "$HIDE ; read psswd ; echo -e $END
				echo ""

				nmcli device wifi connect $ssid password $psswd
				echo ""

				sleep 2

				echo "You want to test your internet connection?"
				echo -ne "[ y/n ]"$BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" ""
				$exit_selection

				ping -c 5 8.8.8.8

				;;

			up)
				echo -e $LIGHTYELLOW"up"$END")" "Update Network Utils"
				echo ""

				echo "Updating netutils ..."
				echo ""

				sleep 1

				cd
				rm -r  Network-Utils/
				mkdir /etc/netutils/

				git clone https://github.com/davidahid/Network-Utils

				mv Network-Utils/scripts/network_utils.sh /etc/netutils/
				mv Network-Utils/scripts/bl.sh /etc/netutils/
				#mv /tmp/Network-Utils/scripts/network_utils.sh /etc/netutils/network_utils.sh

				rm -r Network-Utils/

				clear
				exit

				;;

			1)
				echo -e $LIGHTYELLOW"1"$END")" "Ping"
				echo ""

				echo -e "Which address you want to ping?"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""

				ip_checker $ip_address

				echo -e "From which interface you want to throw the ping?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				echo $response_checker

				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""

				ping -I ${ifaces_array[$selection]} $ip_address

				;;

			2)
				echo -e $LIGHTYELLOW"2"$END")" "Try internet connection"
				echo ""

				echo "Pinging to Google..."
				echo ""
				echo ""
				echo ""

				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""

				ping www.google.es

				;;

			3)
				echo -e $LIGHTYELLOW"3"$END")" "Traceroute"
				echo ""

				echo -e "Which address you want to traceroute?"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""

				ip_checker $ip_address

				echo -e "From which interface you want to throw the ping?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""
				echo ""
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				traceroute --queries=2 --max-hops=10 --interface=${ifaces_array[$selection]} $ip_address

				;;

			4)
				echo -e $LIGHTYELLOW"4"$END")" "Whois"
				echo ""

				echo -e "Enter the IP address to lookup:"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""
				echo ""
				echo ""

				ip_checker $ip_address

				echo "    ____  ____  __  ______    _____   __   _       ____  ______  _________"
				echo "   / __ \/ __ \/  |/  /   |  /  _/ | / /  | |     / / / / / __ \/  _/ ___/"
				echo "  / / / / / / / /|_/ / /| |  / //  |/ /   | | /| / / /_/ / / / // / \__ \   "
				echo " / /_/ / /_/ / /  / / ___ |_/ // /|  /    | |/ |/ / __  / /_/ // / ___/ / "
				echo "/_____/\____/_/  /_/_/  |_/___/_/ |_/     |__/|__/_/ /_/\____/___//____/  "


				whois $ip_address

				;;

			5)
				echo -e $LIGHTYELLOW"5"$END")" "Hops to gateway"
				echo ""

				echo -e "From which interface you want to reach the gateway?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""
				echo ""
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				gateway_ip=`ip route list | grep $selection | grep default | cut -f 3 -d " " | uniq`

				if [ "$gateway_ip" == '' ];
				then
					echo "The interface is not connected to the network."
				else
					traceroute --queries=2 --max-hops=10 --interface=${ifaces_array[$selection]} $gateway_ip
				fi

				;;

			6)
				echo -e $LIGHTYELLOW"6"$END")" "ARP table"
				echo ""

				#Function		First part of the command	Second part of the command
				#command_for_interfaces "arp -i "			""
				command_for_interfaces "arp -i " ""

				;;

			7)
				echo -e $LIGHTYELLOW"7"$END")" "Public IP"
				echo ""

				echo -ne "Your public IP is >>> "$CYAN ; curl icanhazip.com ; echo -e $END

				;;

			8)
				echo -e $LIGHTYELLOW"8"$END")" "Traffic"
				echo ""

				echo -e "With vnstat you can monitor in background all traffic and then generate reports of all the traffic. Also you can calculate the traffic."
				echo -e "With bwm-ng you can monitor all traffic in the interfaces in live. Press "$UNDERRED$BLACK"q or Ctrl+C to exit bwm-ng"$END
				echo -e "What program you want to use?"

				options_selector $number_of_bandwith_program "bandwith_programs_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_bandwith_interface_program"
				$exit_selection

				if [ ${bandwith_programs_array[$selection]} == "bwm-ng" ];
				then
					bwm-ng bwm-ng --allif 2

				elif [ ${bandwith_programs_array[$selection]} == "vnstat" ];
				then
					echo ""
					echo "Select an option to do:"

					echo -e " " $LIGHTYELLOW"start"$END")" "Start vnstat in background"
					echo -e " " $LIGHTYELLOW" stop"$END")" "Stop vnstat in background"
					echo -e " " $LIGHTYELLOW" view"$END")" "View the last report"
					echo -e " " $LIGHTYELLOW" calc"$END")" "Calculate the traffic"
					echo ""
					echo -e " " $LIGHTYELLOW"    0"$END")" "Cancel"
					echo ""
					echo ""

					echo "Type an option:"
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
					echo ""
					echo ""
					echo ""

					case $option in
						start)
							systemctl start vnstat

							;;
						stop)
							systemctl stop vnstat

							vnstat

							;;
						view)
							vnstat

							;;
						calc)
							command_for_interfaces "vnstat --traffic --iface " ""

							;;
						0)
							valid_option=true

							;;
						*)
							clear

							;;
					esac
				fi

				;;

			9)
				echo -e $LIGHTYELLOW"9"$END")" "Traffic by interface"
				echo ""

				echo -e "In which interface you want to monitor the traffic?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				interface=$selection

				echo -e "What program you want to use?"

				echo -ne " " $LIGHTYELLOW"m"$END")"
				printf "$BLUE %-11s $END" "More info"; echo ""

				options_selector $number_of_bandwith_interface_program "bandwith_interface_programs_array"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END

				if [ $selection == "m" ]
				then
					echo ""

					echo -ne " " $LIGHTYELLOW"1"$END")"
					printf "$BLUE %-11s $END >> %-1s" "slurm" "Simple live graphical"; echo ""
					echo -ne " " $LIGHTYELLOW"2"$END")"
					printf "$BLUE %-11s $END >> %-1s" "iftop" "Bytes received and transmited in live to specific destination"; echo ""
					echo -ne " " $LIGHTYELLOW"3"$END")"
					printf "$BLUE %-11s $END >> %-1s" "speedometer" "Simple live graphical"; echo ""
					echo -ne " " $LIGHTYELLOW"4"$END")"
					printf "$BLUE %-11s $END >> %-1s" "tcptrack" "Speed by each open connections"; echo ""
					echo -ne " " $LIGHTYELLOW"5"$END")"
					printf "$BLUE %-11s $END >> %-1s" "ifstat" "X"; echo ""
					echo -ne " " $LIGHTYELLOW"6"$END")"
					printf "$BLUE %-11s $END >> %-1s" "vnstat" "X"; echo ""
					echo -ne " " $LIGHTYELLOW"7"$END")"
					printf "$BLUE %-11s $END >> %-1s" "nload" "X"; echo ""
					echo -ne " " $LIGHTYELLOW"8"$END")"
					printf "$BLUE %-11s $END >> %-1s" "iptraf" "X"; echo ""
					echo ""

					echo -ne " " $LIGHTYELLOW"0"$END")"
					printf "$BLUE %-11s $END" "Exit"; echo ""
					echo ""

					echo -e "If you have any problem with the programs, check if they are installed with the option "$LIGHTYELLOW"chckdep"$END
					echo ""

					echo "Type an option:"
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				fi

				response_checker "$selection" "$number_of_bandwith_interface_program"
				$exit_selection

				program_bandwidth_interface=$selection

				if [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "iftop" ]
				then
					iftop -i ${ifaces_array[$interface]}

				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "speedometer" ]
				then
					speedometer -r ${ifaces_array[$interface]} -t ${ifaces_array[$interface]}

				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "tcptrack" ]
				then
					tcptrack -i ${ifaces_array[$interface]}

				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "slurm" ]
				then
					slurm -i ${ifaces_array[$interface]} -z

				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "ifstat" ]
				then
					ifstat -t -i ${ifaces_array[$interface]} 0.5

				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "vnstat" ]
				then
					vnstat --live --iface ${ifaces_array[$interface]}
#				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "nload" ]
#				then
#
#				elif [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "iptraf" ]
#				then

				fi
				#iftop -i ${ifaces_array[$selection]}

				;;

			10)
				echo -e $LIGHTYELLOW"10"$END")" "Check remote port status"
				echo ""

				echo -e "From which interface yo want to check de remote port status?"
				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				echo -e "Type the host and the port."
				echo -ne $BLINK" >   IP: "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END

				ip_checker $ip_address

				echo -ne $BLINK"> Port: "$END$LIGHTYELLOW ; read port ; echo -ne "\r" $END
				echo ""

				telnet_output=`nmap $ip_address -p $port | grep $port | cut -f 2 -d " "`

				echo ""
				echo -ne $BLUE"PORT STATUS"$END

				if [ "$telnet_output" == "open" ];
				then
					echo -ne $END$LIGHTYELLOW "$ip_address" "$port" $UNDERGREEN$BLACK "OPEN" $END

				elif [ "$telnet_output" == "closed" ];
				then
					echo -ne $END$LIGHTYELLOW "$ip_address" "$port" $UNDERRED$WHITE "CLOSED" $END

				else
					echo -ne $END$LIGHTYELLOW "$ip_address" "$port" $UNDERYELLOW$BLACK "$telnet_output" $END
				fi

				echo ""
				echo ""
				echo ""

				;;

			11)
				echo -e $LIGHTYELLOW"11"$END")" "Ports in use"
				echo ""

				echo -e "Enter the port number or press ENTER to view all ports:"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read port ; echo -ne "" $END
				echo ""

				if [[ $port == '' ]];
				then
					sudo netstat -pant
				else
					echo "Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name"
					sudo netstat -pant | grep $port
				fi

				;;

			12)
				echo -e $LIGHTYELLOW"12"$END")" "Search port info (online)"
				echo ""

				echo -e "Enter the port number:"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read port ; echo -ne "" $END
				echo ""

				echo -e "How you want to view the port info?"
				options_selector $number_of_web_terminals "web_terminals_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""
				response_checker "$selection" "$number_of_web_terminals"

				program_web_terminals=$selection

				if [ ${web_terminals_array[$program_web_terminals]} == "cat" ]
				then
					mkdir /tmp/netutils 2> /dev/null

					lynx -accept_all_cookies -dump "https://es.adminsub.net/tcp-udp-port-finder/"$port > /tmp/netutils/lynx_ports.txt

					total_lines=`wc -l /tmp/netutils/lynx_ports.txt | cut -c1-3`
					lines_below=`cat -n /tmp/netutils/lynx_ports.txt | cut -c4-100 | grep "squedas Recientes" | cut -c1-3`
					lines_above=`cat -n /tmp/netutils/lynx_ports.txt | cut -c4-100 | grep "Buscar los resultados de" | cut -c1-3`

					lines_below=$((lines_below - 1))
					lines_above=$(((lines_above + 1) * -1))

					cat /tmp/netutils/lynx_ports.txt | head -n $lines_below | tac | head -n $lines_above | tac

				elif [ ${web_terminals_array[$program_web_terminals]} == "elinks" ]
				then
					elinks "https://es.adminsub.net/tcp-udp-port-finder/"$port

				elif [ ${web_terminals_array[$program_web_terminals]} == "lynx" ]
				then
					lynx -accept_all_cookies "https://es.adminsub.net/tcp-udp-port-finder/"$port
				fi

				;;

			13)
				echo -e $LIGHTYELLOW"13"$END")" "Firewall rules (iptables)"
				echo ""
				echo ""
				echo ""

				iptables -L

				echo ""
				echo "-----------------------------------"
				echo ""

				iptables -S

				;;

			14)
				echo -e $LIGHTYELLOW"14"$END")" "Route table"
				echo ""
				echo ""
				echo ""

				ip route

				;;

			15)
				echo -e $LIGHTYELLOW"15"$END")" "Check IP blacklist / abuse"
				echo ""

				echo -e "Enter the IP address to lookup:"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""
				echo ""
				echo ""

				echo -e $BLUE">>> AUTONOMOUS SYSTEM <<<"$END
				whois -h whois.cymru.com -- -v "$ip_address"

				echo ""
				echo ""
				echo ""
				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""

				echo -e $BLUE">>> BLACKLISTS <<<"$END
				bash /etc/netutils/bl.sh $ip_address

				;;

			16)
				echo -e $LIGHTYELLOW"16"$END")" "Speed test"
				echo ""

				;;

			17)
				echo -e $LIGHTYELLOW"17"$END")" "Cyber threats search (online)"
				echo ""

				echo -e "Enter the threat name (Example of sintaxis Adware.MAC.Generic.12722):"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read threat ; echo -ne "" $END
				echo ""

				echo -e "How you want to view the port info?"
				options_selector $number_of_web_terminals "web_terminals_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""
				response_checker "$selection" "$number_of_web_terminals"

				program_web_terminals=$selection

				if [ ${web_terminals_array[$program_web_terminals]} == "cat" ]
				then
					clear

					mkdir /tmp/netutils 2> /dev/null

					lynx -accept_all_cookies -dump "https://malwarefixes.com/threats/"$threat > /tmp/netutils/lynx_threats.txt

					total_lines=`wc -l /tmp/netutils/lynx_threats.txt | cut -c1-3`
					lines_below=`cat -n /tmp/netutils/lynx_threats.txt | cut -c4-100 | grep "References" | cut -c1-3`
					lines_above=`cat -n /tmp/netutils/lynx_threats.txt | cut -c4-100 | grep "* [10]Forums" | cut -c1-3`

					lines_below=$((lines_below - 1))
					lines_above=$(((lines_above + 1) * -1))

					cat /tmp/netutils/lynx_threats.txt | head -n $lines_below | tac | head -n $lines_above | tac

				elif [ ${web_terminals_array[$program_web_terminals]} == "elinks" ]
				then
					elinks "https://malwarefixes.com/threats/"$threat

				elif [ ${web_terminals_array[$program_web_terminals]} == "lynx" ]
				then
					lynx -accept_all_cookies "https://malwarefixes.com/threats/"$threat
				fi

				;;

			advif)
				echo -e $LIGHTYELLOW"advif"$END")" "Advanced interface info (nmcli)"
				echo ""

				#Function               First part of the command       Second part of the command
				#command_for_interfaces "ifconfig "                     ""
				command_for_interfaces "nmcli device show " ""

				;;

			sniff)
				echo -e $LIGHTYELLOW"sniff"$END")" "Sniff packets"
				echo ""

				;;

			pping)
				echo -e $LIGHTYELLOW"advping"$END")" "Ping (personalized)"
				echo ""

				echo -e "From which interface you want to throw the ping?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				echo $response_checker

				echo -e "Fill the options:"
				echo -ne $BLINK" >            IP: "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END

				ip_checker $ip_address


				pping_command="ping -I ${ifaces_array[$selection]}"


				echo -ne $BLINK">     Count (n): "$END$LIGHTYELLOW ; read count ; echo -ne "" $END
				if [[ $count != "" ]];
				then
					pping_command="${pping_command} -c ${count}"
				fi

				echo -ne $BLINK">  Interval (s): "$END$LIGHTYELLOW ; read interval ; echo -ne "" $END
				if [[ $interval != "" ]];
				then
					pping_command="${pping_command} -i ${interval}"
				fi

				echo -ne $BLINK">      Size (b): "$END$LIGHTYELLOW ; read size ; echo -ne "" $END
				if [[ $size != "" ]];
				then
					pping_command="${pping_command} -s ${size}"
				fi

				echo -ne $BLINK">       TTL (n): "$END$LIGHTYELLOW ; read ttl ; echo -ne "" $END
				if [[ $ttl != "" ]];
				then
					pping_command="${pping_command} -t ${ttl}"
				fi

				echo -ne $BLINK">  QoS (tclass): "$END$LIGHTYELLOW ; read qos ; echo -ne "" $END
				if [[ $qos != "" ]];
				then
					pping_command="${pping_command} -Q ${qos}"
				fi

				echo ""
				echo ""
				echo ""
				echo -e $BLUE $pping_command $ip_address $END
				echo ""

				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""


				$pping_command $ip_address

				;;

			ovpn)
				echo -e $LIGHTYELLOW"ovpn"$END")" "Connect to a OVPN server"
				echo ""

				mkdir $HOME/.secret
				mkdir $HOME/.secret/ovpns

				if [[ $number_of_ovpns_active > "0" ]];
				then
					echo "There is alredy active connections. Do you want to finish some?"

					options_selector $number_of_ovpns_active "ovpns_active_array"

					echo -ne "[ y/n ]"$BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
					echo ""

					response_checker "$selection" "$number_of_ovpns_active"
					$exit_selection

					clear
					echo "Which connection you want to finish?"

					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
					echo ""

					response_checker "$selection" "$number_of_ovpns_active"
					$exit_selection

					ping -I ${ifaces_array[$selection]} $ping_address


					${ovpns_active_array[$selection}

				elif [[ $ovpns_extracted == '' ]];
				then
					echo "There is no OVPN profiles configured in the system."
					echo "You need to export your OVPN profiles from your OVPN Server to the path $HOME/.secret/ovpns/ of this OVPN client."
				else
					:
				fi

				options_selector $number_of_ovpns "ovpns_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_ovpns"
				$exit_selection

				echo -e $UNDERRED$BLACK"When the connection is established, press Ctrl+Z and the type the command bg. This make the connection work in background."
				echo -e "NOTE: netutils will close." $END
				echo ""

				openvpn --config /root/.secret/ovpns/${ovpns_array[$selection]}

				;;

			cliweb)
				echo -e $LIGHTYELLOW"cliweb"$END")" "Web in CLI (elinks)"
				echo ""

				echo -e "Type the URL of the webpage. Press "$UNDERRED$BLACK"q or Ctrl+C to exit elinks"$END
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read url ; echo -ne "" $END

				elinks $url

				;;

			macman)
				echo -e $LIGHTYELLOW"macman"$END")" "MAC manufacturer"
				echo ""

				echo -e "Type the MAC (required internet):"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read mac ; echo -ne "" $END

				mac=`echo $mac | tr '[a-z]' '[A-Z]' | tr -d ":" | tr -d "." | tr -d [:space:] | cut -c 1-6`
				echo ""
				echo ""

				echo "Vendor:"
				output=`curl https://gist.githubusercontent.com/aallan/b4bb86db86079509e6159810ae9bd3e4/raw/846ae1b646ab0f4d646af9115e47365f4118e5f6/mac-vendor.txt | grep $mac`

				echo -e $CYAN$output$END

				;;

			anon)
				valid_option=false

				echo -e $LIGHTYELLOW"anon"$END")" "Anonymizer"
				echo ""

				while [[ $valid_option == false ]];
				do
					torctlstatus=`torctl status | grep -w "tor service is:" | rev | cut -f1 -d" " | rev`
					anonsurfstatus=`sudo anonsurf status | grep -w "Active:" | tr -s [:space:] ":" | cut -f3 -d":"`
					nordvpnstatus=`nordvpn status | grep -w "Status:" | rev | cut -f1 -d" " | rev`

					options_array=("IP anonymizer for Arch Linux (tor) (activate / deactivate): $torctlstatus" "IP anonymizer for Kali Linux (tor) (activate / deactivate): $anonsurfstatus" "Change MAC address" "Restore MAC address" "NordVPN (activate / deactivate): $nordvpnstatus")
					options_selector 4 "options_array"

					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
					echo ""

					case $option in
						1)
							clear

							#torctlstatus=`torctl status | grep -ow "tor service is: inactive"`

							if [[ $torctlstatus == 'inactive' ]];
							then
								echo -e $GREEN"\n------------- Activating TOR -------------\n"$END
								sudo systemctl start tor
							else
								echo -e $RED"\n------------- Deactivating TOR -------------\n"$END
								sudo systemctl stop tor
							fi

							;;

						2)
							;;
						3)
							clear

							iface=`ip addr | awk '/state UP/ {print $2}' | sed 's/.$//'`

							ip link set $iface down
							output=`macchanger --another $iface`
							ip link set $iface up

							#echo -e $output | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
							echo -e $CYAN"\n"$output | sed 's/) /)\n/g'; echo -e $END

							#valid_option=true

							;;

						4)
						clear

						iface=`ip addr | awk '/state UP/ {print $2}' | sed 's/.$//'`

						ip link set $iface down
						output=`macchanger --permanent $iface`
						ip link set $iface up

						#echo -e $output | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
						echo -e $CYAN"\n"$output | sed 's/) /)\n/g'; echo -e $END
						;;

						5)
						clear

						path_nordvpn=`which nordvpn`

						if [[ $path_nordvpn == '' ]];
						then
							echo -e "																																																										"
							echo -e $UNDERRED$BLACK"NordVPN not installed."$END" To install it follow the next instructions: 														"
							echo -e "																																																										"
							echo -e $UNDERWHITE$BLACK"Debian or Ubuntu distros                                                                                          "$END
							echo -e "                                                                                                                   "
							echo -e "https://blog.sleeplessbeastie.eu/2019/02/04/how-to-use-nordvpn-command-line-utility/                               "
							echo -e "                                                                                                                   "
							echo -e $GREEN"sudo apt install wget apt-transport-https                                                                    "
							echo -e "wget --directory-prefix /tmp https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb   "
							echo -e "sudo apt install /tmp/nordvpn-release_1.0.0_all.deb                                                                "
							echo -e "sudo apt update                                                                                                    "
							echo -e "sudo apt install nordvpn                                                                                     	    "$END
							echo -e "                                                                                                                   "
							echo -e "                                                                                                                   "
							echo -e $UNDERWHITE$BLACK"Arch distro                                                                                                       "$END
							echo -e "                                                                                                                   "
							echo -e "https://wiki.archlinux.org/index.php/NordVPN                                                                       "
							echo -e "                                                                                                                   "
							echo -e $GREEN"pacman -S ca-certificates                                                                                    "
							echo -e "pacman -S iproute2                                                                                                 "
							echo -e "pacman -S ipset                                                                                                    "
							echo -e "pacman -S iptables                                                                                                 "
							echo -e "pacman -S libxslt                                                                                                  "
							echo -e "pacman -S procps                                                                                                   "
							echo -e "git clone https://aur.archlinux.org/nordvpn-bin.git                                                                "
							echo -e "cd nordvpn-bin                                                                                                     "
							echo -e "makepkg                                                                                                            "
							echo -e "pacman -U nordvpn-bin-3.8.4-1-x86_64.pkg.tar.zst                                                                   "$END
						else
							if [[ $nordvpnstatus == 'Disconnected' ]];
							then
								echo -e $GREEN"\n------------- Connecting to NordVPN -------------\n"$END

								echo -e $BLUE
								nordvpn countries
								echo -e $END

								echo -e "\nType the country you want to connect to:"
								echo -ne $BLINK" > "$END$LIGHTYELLOW ; read country ; echo -ne "" $END
								echo ""

								nordvpn connect $country

								echo -e $CYAN
								nordvpn status
								echo -e $END
							else
								echo -e $RED"\n------------- Disconnecting from NordVPN -------------\n"$END

								nordvpn disconnect

								echo -e $CYAN
								nordvpn status
								echo -e $END
							fi
						fi

						;;

					0)
						valid_option=true

						;;
					*)
						clear

						;;
				esac

			done


#					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read mac ; echo -ne "" $END
#
#					mac=`echo $mac | tr '[a-z]' '[A-Z]' | tr -d ":" | tr -d "." | tr -d [:space:] | cut -c 1-6`
#					echo ""
#
#					echo -e $CYAN ; curl https://gist.githubusercontent.com/aallan/b4bb86db86079509e6159810ae9bd3e4/raw/846ae1b646ab0f4d646af9115e47365f4118e5f6/mac-vendor.txt | grep $mac ; echo -e $END
					;;
			0)
				exit

				;;

			*)
				invalidoption=true

				;;
			esac

			exit_selection=true
		done

	#If the user type an invalid option...
	if [[ $invalidoption == true ]];
	then
		#...do nothing
		:

	#...but if the option is included in the case
	elif [[ $invalidoption == false ]];
	then
		#Waits for user to press the enter key after he view what he need
		echo ""
		echo ""
		echo -ne $UNDERGRAY$BLACK"Press ENTER to go back to the main menu"$END
		tput civis
		read
		tput cnorm

	elif [[ $exit_selection == true ]];
	then
		invalidoption=false
	fi

	#Set all control variables to default
	#selected_interface=""
	#option=""
done
