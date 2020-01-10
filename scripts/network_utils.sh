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
BLUE="\e[34m"
BLACK="\e[30m"
WHITE="\e[37m"
CYAN="\e[36m"
LIGHTYELLOW="\e[1;33m"

UNDERRED="\e[41m"
UNDERGREEN="\e[42m"
UNDERWHITE="\e[107m"
UNDERGRAY="\e[47m"
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

programs_array=(ping nmcli traceroute telnet iftop iptraf-ng nethogs slurm tcptrack vnstat bwm-ng bmon ifstat speedometer openvpn nmap tshark sipcalc nload)
bandwith_interface_programs_array=(slurm iftop speedometer tcptrack ifstat vnstat nload iptraf)
bandwith_programs_array=(vnstat bwm-ng)

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

	echo -e $TAB$LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"$TAB	$TAB$LIGHTYELLOW"wc"$END")" "Connect to Wifi (nmcli)"
	echo -e $TAB$LIGHTYELLOW" 1"$END")" "Ping"$TAB$TAB			$TAB$TAB$LIGHTYELLOW" 2"$END")" "Try internet connection"	$TAB$TAB$LIGHTYELLOW" 3"$END")" "Traceroute"$TAB
	echo -e $TAB$LIGHTYELLOW" 4"$END")" "Hops to gateway"$TAB$TAB		$TAB$LIGHTYELLOW" 5"$END")" "ARP table"$TAB$TAB			$TAB$TAB$LIGHTYELLOW" 6"$END")" "Public IP"$TAB
	echo -e $TAB$LIGHTYELLOW" 7"$END")" "Traffic"				$TAB$TAB$TAB$TAB$LIGHTYELLOW" 8"$END")" "Traffic by interface" $TAB$TAB$LIGHTYELLOW" 9"$END")" "Check remote port status"
	echo -e $TAB$LIGHTYELLOW"10"$END")" "Ports in use"$TAB			$TAB$TAB$LIGHTYELLOW"11"$END")" "Firewall rules (iptables)"	$TAB$TAB$LIGHTYELLOW"12"$END")" "Route table"
	echo -e $TAB$LIGHTYELLOW"13"$END")" "Sniff packets"$TAB
	echo ""
	echo ""



	echo -e $BLUE"  >>> ADVANCED <<<  "$END
	echo ""

	echo -e $LIGHTYELLOW"     advif"$END")" "Advanced interfaces info"
	echo -e $TAB$LIGHTYELLOW" X"$END")" "Ping (personalized)"$TAB$TAB	$TAB$LIGHTYELLOW" X"$END")" "Traceroute (personalized)"
	echo -e $LIGHTYELLOW"      ovpn"$END")" "Connect to a OVPN server"
	echo ""
	echo ""



	if [[ $invalidoption == true ]];
	then
		echo "Wut? I guess this is not a valid option... :/"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
		echo ""
	else
		echo "Type an option:"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
		echo ""
	fi
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

	for (( whatever_number=1; whatever_number<=$1; whatever_number++ ));
	do
		echo -e " " $LIGHTYELLOW$whatever_number$END") "$BLUE${array[$whatever_number]}$END
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
			exit_selection="break"
			return

		elif [ $selection -lt $number_of_options ] || [ "$selection" == "y" ];
		then
			break

		else
			echo -e "Type a valid option:"
			echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
			echo ""
		fi
	done

	echo ""
}

ip_checker()
{
	ip_address=$1
	ip_address_format=`echo $ip_address | egrep "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" `

	while [ "$ip_address" != "$ip_address_format" ];
	do
		echo -e "Please, type a valid IP:"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
		echo ""

		ip_address_format=`echo $ip_address | egrep "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" `
	done

	exit_selection=false

	echo ""
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
			sudo apt-get --assume-yes $1 $2 ${programs_array[$program]} > /dev/null

		elif [[ ${programs_array[$program]} == "nmcli" ]];
		then
			sudo apt-get --assume-yes install network-manager > /dev/null
			
		elif [[ $path_actual_program == "/"* && $option == "ud" && ${programs_array[$program]} == "ping" || ${programs_array[$program]} == "nmcli" || ${programs_array[$program]} == "traceroute" ]];
		then
			echo "Omiting ${programs_array[$program]} ..."
			sleep 0.5

		elif [[ $path_actual_program == "/"* && $option == "ud" ]];
		then
			echo "Unistalling ${programs_array[$program]} ..."
			echo ""

			sudo apt-get --assume-yes $1 $2 ${programs_array[$program]} > /dev/null
		fi

		#program_name=""
		path_actual_program=""

		clear
		show_programs
	done
}

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
					exit_selection=true
				done

				;;
			if)
				echo -e $LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"
				echo ""

				#Function		First part of the command	Second part of the command
				#command_for_interfaces "ifconfig "			""
				command_for_interfaces "ifconfig " ""

				;;
			advif)
				echo -e $LIGHTYELLOW"advif"$END")" "Advanced interface info (nmcli)"
				echo ""

				#Function               First part of the command       Second part of the command
				#command_for_interfaces "ifconfig "                     ""
				command_for_interfaces "nmcli device show " ""

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
				rm -r  /tmp/Network-Utils/
				mkdir /tmp/Network-Utils/

				git clone https://github.com/davidahid/Network-Utils

				mv Network-Utils/* /tmp/Network-Utils/
				mv /tmp/Network-Utils/scripts/network_utils.sh /etc/netutils/network_utils.sh

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
				echo -e $LIGHTYELLOW"4"$END")" "Hops to gateway"
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
			5)
				echo -e $LIGHTYELLOW"5"$END")" "ARP table"
				echo ""
				echo ""
				echo ""

				#Function		First part of the command	Second part of the command
				#command_for_interfaces "arp -i "			""
				command_for_interfaces "arp -i " ""

				;;
			6)
				echo -e $LIGHTYELLOW"6"$END")" "Public IP"
				echo ""
				echo ""
				echo ""

				echo -ne "Your public IP is >>> "$CYAN ; curl icanhazip.com ; echo -e $END

				;;
			7)
				echo -e $LIGHTYELLOW"7"$END")" "Traffic"
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
			8)
				echo -e $LIGHTYELLOW"8"$END")" "Traffic by interface"
				echo ""

				echo -e "In which interface you want to monitor the traffic?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection
				
				interface=$selection

				echo -e "What program you want to use?"

				options_selector $number_of_bandwith_interface_program "bandwith_interface_programs_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				while [ $selection == "m" ];
				do
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				done

				response_checker "$selection" "$number_of_bandwith_interface_program"
				$exit_selection

				program_bandwidth_interface=$selection

				if [ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "iftop" ];
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
			9)
				echo -e $LIGHTYELLOW"9"$END")" "Check remote port status"
				echo ""

				echo -e "From which interface yo want to check de remote port status?"
				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				$exit_selection

				echo -e "Type the host and the port."
				echo -ne $BLINK"   IP: "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END

				ip_checker $ip_address

				echo -ne $BLINK" Port: "$END$LIGHTYELLOW ; read port ; echo -ne "" $END
				echo ""
				
				telnet_output=`nmap $ip_address -p $port | grep $port | cut -f 2 -d " "`

				if [ "$telnet_output" == "open" ];
				then
					echo -ne $END$LIGHTYELLOW "$ip_address" "$port" $UNDERGREEN$BLACK "OPEN" $END

				elif [ "$telnet_output" == "closed" ];
				then
					echo -ne $END$LIGHTYELLOW "$ip_address" "$port" $UNDERRED$WHITE "CLOSED" $END
				
				else
					echo -ne $END$LIGHTYELLOW "$ip_address" "$port" $UNDERYELLOW$BLACK "$telnet_output" $END
				fi
				;;
			10)
				echo -e $LIGHTYELLOW"10"$END")" "Ports in use"
				echo ""

				;;
			11)
				echo -e $LIGHTYELLOW"11"$END")" "Firewall rules iptables"
				echo ""

				;;
			12)
				echo -e $LIGHTYELLOW"12"$END")" "Route table"
				echo ""

				;;
			13)
				echo -e $LIGHTYELLOW"12"$END")" "Sniff packets"
				echo ""

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
	else
		#Waits for user to press the enter key after he view what he need
		echo ""
		echo ""
		echo -ne $UNDERGRAY$BLACK"Press ENTER to go back to the main menu"$END
		tput civis
		read
		tput cnorm
	fi

	#Set all control variables to default
	#selected_interface=""
	#option=""
done
