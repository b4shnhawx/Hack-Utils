#!/bin/bash

#---------------- FORMATING VARIABLES -------------
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

##---------------- FIRST OF ALL ----------------
## Read the config file. Create al directories located in the .conf file and save the directories and the configs in the specified array.
##	ARRAY 					CONFIG:
##	${directories_array[0]}		OVPN_DIR
##	${directories_array[1]}		HTB_DIR
##	${directories_array[2]}		TMP_DIR
##	${directories_array[3]}		CONKY_DIR
##	${directories_array[4]}		CONKYRC_DIR
##	${directories_array[5]}		SCRIPTS_DIR
##	${directories_array[6]}		HTTP_DIR
##	${configurations_array[0]}	HTB_OVPN_NAME

while IFS= read -r line
do
	config=`echo $line | cut -f2 -d"="`

	if [[ $line == *"HOME"* && $line == *"DIR"* ]];
	then
		home=`echo $HOME | rev`
		dir=`echo -n $config | cut -c6-100 | rev`
		dir=$dir$home
		dir=`echo $dir | rev`
		
		mkdir -p $dir

		directories_array=("${directories_array[@]}" $dir)

	elif [[ "$line" == *"DIR"* ]]; 
	then
		dir=$config

		mkdir -p $dir	

		directories_array=("${directories_array[@]}" $dir)
	else
		configurations_array=("${configurations_array[@]}" $config)
	fi
done < /etc/hackutils/hack_utils.conf

#---------------- VARIABLES -------------
#Version
version="0.7.3"
last_version=`curl -s https://raw.githubusercontent.com/b4shnhawx/Hack-Utils/master/version.txt`
#All interfaces in used in the system
interfaces_extracted=`ip addr | grep ^[0-9]: | cut -f 2 -d ":" | sed 's/ //g' | tr '\n' " "`
#All wlanX interfaces in used in the system
wlan_interfaces_extracted=`ip addr | grep ^[0-9]: | cut -f 2 -d ":" | sed 's/ //g' | egrep -o "wlan[0-9]{1,2}" | tr '\n' " "`
#All OVPNS profiles used in the system in one column
ovpns_extracted=`ls --width=1 ${directories_array[0]} | tr '\n' " "`


#Transforms the strings into arrays
read -a ifaces_array <<< $interfaces_extracted
read -a wlan_ifaces_array <<< $wlan_interfaces_extracted
read -a ovpns_array <<< $ovpns_extracted


programs_array=(rlwrap ping nmcli traceroute telnet iftop iptraf-ng nethogs slurm tcptrack vnstat bwm-ng bmon ifstat speedometer openvpn nmap tshark sipcalc nload speedtest-cli lynx elinks macchanger nordvpn anonsurf torctl bc teamviewer jq htbExplorer aircrack-ng tmux conky hostapd dnsmasq netcat)
bandwith_interface_programs_array=(slurm iftop speedometer tcptrack ifstat vnstat nload bwm-ng)
web_terminals_array=(cat elinks lynx)

#Saves how many interfaces have the system
number_of_interfaces=${#ifaces_array[@]}
#Saves how many wlan interfaces have the system
number_of_wlan_interfaces=${#wlan_ifaces_array[@]}
#Saves how many ovpns profiles have the system
number_of_ovpns=${#ovpns_array[@]}
#Saves how many programs are used in this script
number_of_programs=${#programs_array[@]}
#Saves how many programs to monitor the traffic are used in this script
number_of_bandwith_interface_program=${#bandwith_interface_programs_array[@]}
number_of_web_terminals=${#web_terminals_array[@]}

#---------------- FUNCTIONS ----------------
menu()
{
	clear

	printf "\n"$RED$BOLD
	printf "            .                                                                     ╹┃\n"
	printf "            #.  .                     ┏━       ╻ ╻┏━┓┏━╸╻┏    ╻ ╻╺┳╸╻╻  ┏━┓        ╻╹\n"
	printf "           .#|##|.    .|              ╹        ┣━┫┣━┫┃  ┣┻┓   ┃ ┃ ┃ ┃┃  ┗━┓        ┃╹\n"
	printf "          .#|#####||.###.             ┃╹       ╹ ╹╹ ╹┗━╸╹ ╹╺━╸┗━┛ ╹ ╹┗━╸┗━┛       ━┛  $GREEN v$version $RED\n"
	printf "                                     ╹┃         by$PURPLE b4shnhawx $RED\n"
	printf "\n"
	printf "01111001 01101111 01110101 00100000 01100110 01101111 01110101 01101110 01100100 00100000 01101101 01111001 00100000\n"
	printf "     01100101 01100001 01110011 01110100 01100101 01110010 00100000 01100101 01100111 01100111 00100000 00111011 00101001\n"
	printf "\n"$END

	echo -e $CYAN$BOLD"  >>> MISCELLANEOUS <<<  "$END
	echo ""

	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-0s$END " 							   	 "chckdep" ")" "Check all the dependencies"   		"up" 	")" "Update Hack_Utils"; echo -e "(Last git version:$BOLD$GREEN v$last_version$END)"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 							   		"conf" ")" "Modify Hack_utils config file"  	"" 	"" ""
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 								 	   "0" ")" "Exit"								"conky" ")" "Setup conky desktop"
	echo ""

	echo -e $CYAN$BOLD"  >>> BASICS <<<  "$END
	echo ""

	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	"if" ")" "Interfaces info (ifconfig)" 	"wc" ")" "Connect to Wifi (nmcli)"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	"tv" ")" "Teamviewer" 	"" "" ""
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	 "1" ")" "Ping"							 "2" ")" "Try internet connection"			"3" ")" "Traceroute"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	 "4" ")" "Whois"						 "5" ")" "Hops to gateway"					"6" ")" "ARP table"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	 "7" ")" "Public IP"					 "8" ")" "Traffic monitoring (iptraf)"		"9" ")" "Traffic monitoring ($number_of_bandwith_interface_program utilities)"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	"10" ")" "Check remote port status"	 	"11" ")" "Ports in use"					   "12" ")" "Search port info (online)"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	"13" ")" "Firewall rules (iptables)"	"14" ")" "Route table"					   "15" ")" "Check IP blacklist / abuse"
	printf "$LIGHTYELLOW %9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END$LIGHTYELLOW%9s$END%-0s %-29s$END \n" 	"16" ")" "Internet speed test"			"" "" ""   "" "" ""
	echo ""

	echo -e $CYAN$BOLD"  >>> ADVANCED <<<  "$END
	echo ""

	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 								 	"advif"		")" "Advanced interfaces info" 						"sniff" 	")" "Sniff packets"
	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 								  	"ovpn" 		")" "Connect to a OVPN server" 				 		"anon" 		")" "Anonymizer"
	printf "$RED %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 							    			"sshtun" 	")" "SSH tunneling"			 				 		"pping" 	")" "Ping (personalized)"
	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 									"macman" 	")" "MAC manufacturer" 	   				   			"cliweb" 	")" "Web in CLI (elinks)"
	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 						       		"malware" 	")" "Cyber threats search (Malware Bazaar API)" 	"conv" 		")" "Hexadecimal / Base64 converter"
	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 								  	"fkap" 		")" "Fake Access Point: Evil twin" 					"dwa" 		")" "Deauth Wireless Attack"
	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 								  	"htb" 		")" "Hack The Box" 					 				"rev" 		")" "Listener for reverse shells connections"
	printf "$LIGHTYELLOW %9s$END%-0s %-45s$END$LIGHTYELLOW%9s$END%-0s %-45s$END \n" 								  	"" 		"" "" 					 								"http"		")" "Python simple HTTP server"
	echo ""

	echo "Use Ctrl+C any time to go back to menu. Type an option:"
#	echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END

	if [[ $(which rlwrap) == "" ]];
	then
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END

	else
		options=(chckdep up conf 0 conky if wc tv 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 advif sniff ovpn anon sshtun pping macman cliweb malware conv fkap dwa htb rev http)

		echo -ne $LIGHTYELLOW
		option=$(rlwrap -D 0 -S ' > ' -i -f <(echo -ne "${options[@]}") -o cat)
		echo -ne $END

	fi
#	option=$(rlwrap -S ' > ' -i -f list.txt)
#	option=$(rlwrap -i -f <(echo -ne "$BLINK > ${ynm[@]}") -o cat)
#	option=$(rlwrap -i -f <(cat ${ynm[@]})
#	option=$(rlwrap -f <(echo "${ynm[@]}") -o cat)

#	echo ""
}

#Function for wait 12 seconds
waitFunction()
{
	repeats=$1
	milisec=$2
	#Hide the cursor to view the waiting bar without the backgorund color of the cursor
	tput civis

	#Bucle that repeats 3 times
	for count in [ 0..$repeats ];
	do
		#Print compatible with format (-e) and without new line (-n).
		#With the \\r (\r carriage return) we erase the first char of the line,
		#so we can write another character in the same line without the prev char.
		echo -ne $LIGHTYELLOW"| \\r"$END
		sleep $milisec
		echo -ne $LIGHTYELLOW"/ \\r"$END
		sleep $milisec
		echo -ne $LIGHTYELLOW"- \\r"$END
		sleep $milisec
		echo -ne $LIGHTYELLOW"\ \\r"$END
		sleep $milisec
	done

	#Show again the cursor.
	tput cvvis

	#Erase the last character of the waitFunction and then go to the next line
	echo -ne " \\r"
}

command_for_interfaces()
{
	echo -e "Available interfaces:"$CYAN$BOLD ${ifaces_array[@]}
	echo ""

	for (( interface_number=0; interface_number<$number_of_interfaces; interface_number++ ));
	do
		echo -e $CYAN$BOLD" > "${ifaces_array[$interface_number]} $END
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
		echo -e " " $LIGHTYELLOW$whatever_number$END") "$CYAN$BOLD${array[$whatever_number]}$END | sed ''/inactive/s//`printf "\033[31mdisabled\033[0m"`/'' | sed ''/active/s//`printf "\033[32menabled\033[0m"`/'' | sed ''/Disconnected/s//`printf "\033[31mdisconnected\033[0m"`/'' | sed ''/Connected/s//`printf "\033[32mconnected\033[0m"`/''
	done

	echo ""
	echo -e " " $LIGHTYELLOW"0"$END") "$CYAN$BOLD${array[0]}$END
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
		if [[ "$selection" == "0"  ||  "$selection" == "n" ]];
		then
			selection="exit"
			invalidoption=true

			ignore_continue_enter=true

			break

		elif [[ "$selection" < $number_of_options || "$selection" == "y" ]];
		then
			break

		else
			echo ""
			echo -e "Type a valid option:"
			echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
			echo ""

			## If selection is 0, exit this option
			if [[ $selection == "exit" ]]; then break; fi
		fi
	done
}

ip_checker()
{
	ip_address=$1
	ip_address_format=`echo $ip_address | egrep "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" `

	while [ "$ip_address" != "$ip_address_format" ] || [ "$ip_address" == "" ];
	do
		echo ""
		echo -e "Please, type a valid IP:"
		echo -ne $BLINK" >  "$END" IP: "$LIGHTYELLOW ; read ip_address ; echo -ne "" $END

		ip_address_format=`echo $ip_address | egrep "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" `
	done

	exit_selection=false
}

port_checker()
{
	port=$1

	while [[ $port -lt 1 || $port -gt 65535 || $port == *[a-zA-Z]* ]];
	do
		echo "Type a valid port number:"
		echo -ne $BLINK" > "$END$LIGHTYELLOW ; read port ; echo -ne "" $END
		echo ""
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
	
	echo -e "\nList of programs you must install manually:"
	echo -e "\ttorctl (only for Arch Linux)"
	echo -e "\tkali-anonsurf (only for Kali Linux)"
	echo -e "\tnordvpn"
	echo -e "\tteamviewer"
	echo -e "\thtbExplorer"
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
		echo -e $CYAN$BOLD"Checking ${programs_array[$program]} ..."$END
		sleep 0.1

		if [[ $path_actual_program == '' && $option == "id" ]];
		then
			echo -e $CYAN$BOLD"Installing ${programs_array[$program]} ..."$END
			echo ""

			#echo "sudo apt-get --assume-yes $1 ${programs_array[$program]} > /dev/null"
			sudo DEBIAN_FRONTEND=noninteractive apt-get --assume-yes $1 $2 ${programs_array[$program]} &> /dev/null
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

malware_score_checker()
{
	score=$1

	if [ $score == "null" ];
	then
		echo -e $GREEN$BOLD"Neutral"$END

	elif [ $score -lt 3 ];
	then
		echo -e $GREEN$BOLD"$score / 10"$END

	elif [ $score -lt 8 ];
	then
		echo -e $LIGHTYELLOW$BOLD"$score / 10"$END
					
	elif [ $score -gt 7 ];
	then
		echo -e $RED$BOLD"$score / 10"$END
	fi
}

#---------------- SCRIPT ----------------
while true;
do
	#Variables and arrays that must check every time
	#Extract the active connections
	ovpns_active_extracted=`ps aux | grep openvpn | grep "${directories_array[0]}" | rev | cut -f1 -d "/" | rev | tr '\n' " "`
	#Saves the active connectios into array
	read -a ovpns_active_array <<< $ovpns_active_extracted
	#Saves how many ovpns active connections have the system
	number_of_ovpns_active=${#ovpns_active_array[@]}

	echo -e $END
	ignore_continue_enter=false

	#Starts the main screen
	menu
	#When user select an option, sets the parameter for distinguise an invalid option in false
	invalidoption=false

	clear

	while [[ $invalidoption == false ]];
	do
		#Catch Ctrl+C to break the bucles and go back menu
		trap 'invalidoption="ignore"; tput civis; echo -e "\n\n$UNDERGRAY$BLACK Exit signal. Press enter to go back. $END$HIDE"; break; tput cnorm;' INT

		case $option in
			chckdep*)
				show_programs
				echo ""
				echo ""
				echo -e " " $LIGHTYELLOW" id"$END")" "Install all the dependencies (before install, exit hackutils and type apt-get update && apt-get upgrade)"
				echo -e " " $LIGHTYELLOW" ud"$END")" "Uninstall all the dependencies (except ping, nmcli and traceroute)"
				echo -e " " $LIGHTYELLOW"man"$END")" "View steps to install the programs that must be installed manually"
				echo ""
				echo -e " " $LIGHTYELLOW" 0"$END")" "Cancel"
				echo ""
				echo ""
				echo "Type an option:"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
				echo ""

				case $option in
					id)
						install_uninstall_programs_array "install" "" "$option"
						echo ""
						echo -e $CYAN$BOLD"If you have some problems installing some programs, enter --> apt-get install --fix-missing"$END

						invalidoption=false

					;;

					ud)
						install_uninstall_programs_array "" "purge" "$option"

						invalidoption=false

					;;

					man)
						clear
						
						echo -e $UNDERWHITE$BLACK"\nTORCTL                                                                                            "$END
						echo -e $UNDERWHITE$BLACK"     Arch distros                                                                                            "$END
						echo -e "														    "
						echo -e $CYAN$BOLD"https://github.com/BlackArch/torctl									    "$END
						echo -e "                                                                                                                   "
						echo -e $GREEN"pacman -S torctl												    "$END
						
						echo -e $UNDERWHITE$BLACK"\n\nANONSURF                                                                                          "$END
						echo -e $UNDERWHITE$BLACK"     Kali Linux                                                                                         "$END
						echo -e "														    "
						echo -e $CYAN$BOLD"https://github.com/Und3rf10w/kali-anonsurf.git								    "$END
						echo -e "                                                                                                                   "
						echo -e $GREEN"git clone https://github.com/Und3rf10w/kali-anonsurf.git							    "$END
						echo -e $GREEN"cd kali-anonsurf							 					    "$END
						echo -e $GREEN"sudo bash installer.sh							  				    "$END
						
						echo -e $UNDERWHITE$BLACK"\n\nNORDVPN                                                                                           "$END
						echo -e $UNDERWHITE$BLACK"     Debian or Ubuntu distros                                                                          "$END
						echo -e "                                                                                                                   "
						echo -e $CYAN$BOLD"https://blog.sleeplessbeastie.eu/2019/02/04/how-to-use-nordvpn-command-line-utility/                          "$END
						echo -e "                                                                                                                   "
						echo -e $GREEN"sudo apt install wget apt-transport-https                                                                    "
						echo -e "wget --directory-prefix /tmp https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb   "
						echo -e "sudo apt install /tmp/nordvpn-release_1.0.0_all.deb                                                                "
						echo -e "sudo apt update                                                                                                    "
						echo -e "sudo apt install nordvpn                                                                                     	    "$END
						echo -e "                                                                                                                   "
						echo -e "                                                                                                                   "
						echo -e $UNDERWHITE$BLACK"     Arch distro                                                                                       "$END
						echo -e "                                                                                                                   "
						echo -e $CYAN$BOLD"https://wiki.archlinux.org/index.php/NordVPN                                                                  "$END
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
						
						echo -e $UNDERWHITE$BLACK"\n\nTEAMVIEWER                                                                                          "$END
						echo -e $UNDERWHITE$BLACK"     Kali Linux                                                                                         "$END
						echo -e "														    "
						echo -e $CYAN$BOLD"https://newvo.com.au/how-to-install-teamviewer-on-linux-cli/						    "$END
						echo -e "                                                                                                                   "
						echo -e $GREEN"cd ~/Downloads													    "$END
						echo -e $GREEN"wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb				  	    "$END
						echo -e $GREEN"sudo apt install ./teamviewer_amd64.deb									    "$END
						
						echo -e $UNDERWHITE$BLACK"\n\htbExplorer                                                                                          "$END
						echo -e $UNDERWHITE$BLACK"     Any (GitHub)                                                                                     "$END
						echo -e "														    "
						echo -e $CYAN$BOLD"https://github.com/s4vitar/htbExplorer.git					    "$END
						echo -e "                                                                                                                   "
						echo -e $GREEN"cd ~/Downloads													    "$END
						echo -e $GREEN"git clone https://github.com/s4vitar/htbExplorer.git 				"$END
						echo -e $GREEN"cd htbExplorer		  	    										"$END
						echo -e $GREEN"cp htbExplorer htbExplorer_tmp"$END
						echo -e $GREEN"cat htbExplorer_tmp | sed 's/API_TOKEN=""/API_TOKEN=\""$CYAN$BOLD"YOUR_HTB_API_TOKEN\""$END$GREEN"/g' > htbExplorer									    "$END
						echo -e $GREEN"sudo cp downloadVPN.py /etc/hackutils/ 									    "$END
						echo -e $GREEN"sudo cp htbExplorer /etc/hackutils/ 									    "$END
						echo -e $GREEN"sudo cp htbExplorer /usr/bin 									    "$END
						echo -e $GREEN"sudo chmod +x /usr/bin/htbExplorer 										"$END
					
					;;

					0)
						ignore_continue_enter=true

					;;

					*)
						invalidoption=true
						ignore_continue_enter=false	

					;;
				esac

			;;

			if*)
				echo -e $LIGHTYELLOW"if"$END")" "Interfaces info (ifconfig)"
				echo ""

				#Function		First part of the command	Second part of the command
				#command_for_interfaces "ifconfig "			""
				command_for_interfaces "ifconfig " ""

			;;

			tv*)
				echo -e $LIGHTYELLOW"tv"$END")" "Teamviewer"
				echo ""
				#Function		First part of the command	Second part of the command
				#command_for_interfaces "ifconfig "			""
				
				echo -e "What you want to do?"

				options_array=("Connect to TeamViewer server" "Setup this TeamViewer server")
				options_selector 2 "options_array"
			
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				case $selection in
					1)
						echo -e $CYAN$BOLD"Killing previous instaces of TeamViewer GUI..."$END

						sudo pklill teamviewer
						waitFunction "6" "0.10"	

						if [[ $? != 0 ]];
						then

							echo -e $RED "An error was ocurred while try execute TeamViewer (probably related with the user that launch the program)."

							break
						fi

						echo -e $CYAN$BOLD"Executing TeamViewer GUI..."$END

						sudo teamviewer daemon start
						waitFunction "6" "0.10"
						nohup sudo teamviewer &

					;;

					2)
						sudo teamviewer daemon disable > /dev/null
						sudo teamviewer daemon restart > /dev/null
		
						teamviewer info
						echo ""
		
						output=`teamviewer info | grep "TeamViewer ID:" | egrep -o '[0-9]{7,12}'`
						teamviewer info | grep "TeamViewer ID:" | tr -d [[:space:]] | cut -c4-16,20-30 | sed 's/TeamViewerID:/TeamViewer ID: /g' | sed ''/[0-9]*$/s//`printf "$CYAN$BOLD$output$END"`/''

						echo "You want to setup a new password to this TeamViewer server?"
						echo -ne "[ y/n ]"$BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
						echo ""

						response_checker "$selection" ""
						
						if [[ $selection == "exit" ]]; then break; fi

						echo "Type your new password:"
						echo -ne $BLINK" > "$END$LIGHTYELLOW ; read psswd ; echo -ne "" $END
						echo ""

						teamviewer passwd $psswd

					;;

					0)
						ignore_continue_enter=true

						break

					;;

					*)
						invalidoption=true
						ignore_continue_enter=false	

					;;
	

				esac


				;;

			wc*)
				echo -e $LIGHTYELLOW"wc"$END")" "Connect to Wifi (nmcli)"
				echo ""

				nmcli device wifi rescan

				## If there is an error executing the last command, will break the case statement.
				if [[ $? != 0 ]];
				then
					echo -e $RED "An error was ocurred while try to scan the wireless networks (probably not a valid wireless interface detected)."

					break
				fi

				nmcli device wifi list
				echo ""

				echo -ne "SSID: "$LIGHTYELLOW ; read ssid ; echo -ne $END
				echo -ne "Password: "$HIDE ; read psswd ; echo -e $END
				echo ""

				nmcli device wifi connect $ssid password $psswd

				## If there is an error executing the last command, will break the case statement.
				if [[ $? != 0 ]];
				then
					echo -e $RED "An error was ocurred while try to connect to the AP (probably incorrect password)."

					break

				fi

				waitFunction "5" "0.40"

				echo -e $CYAN$BOLD" > You are now connected to $ssid" $END
				echo ""

				echo "You want to test your internet connection?"
				echo -ne "[ y/n ]"$BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" ""

				if [[ "$selection" == "exit" ]]; then break; fi
				
				ping -c 5 www.google.com

				;;

			up*)
				echo -e $LIGHTYELLOW"up"$END")" "Update Hack_Utils"
				echo ""

				echo -e $CYAN$BOLD" > Updating Hack_Utils..." $END
				echo ""

				waitFunction "5" "0.40"

				cd
				rm -r  Hack-Utils/
				mkdir /etc/hackutils/

				git clone https://github.com/davidahid/Hack-Utils

				mv Hack-Utils/scripts/hack_utils.sh /etc/hackutils/
				mv Hack-Utils/scripts/bl.sh /etc/hackutils/
				#mv /tmp/Network-Utils/scripts/network_utils.sh /etc/hackutils/network_utils.sh

				rm -r Hack-Utils/

				clear
				exit

				;;

			conky*)
				echo -e $LIGHTYELLOW"conky"$END")" "Setup conky desktop"
				echo ""

				echo -e "What interface you want to monitor in conky?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"					

				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				curl https://raw.githubusercontent.com/b4shnhawx/Hack-Utils/master/scripts/conky/.conkyrc > /etc/hackutils/conky/.conkyrc

				waitFunction "5" "0.20"

				rm ${directories_array[3]}Conky.desktop
				rm ${directories_array[4]}.conkyrc
				rm ${directories_array[5]}internet_test.sh

				echo "Copying: /etc/hackutils/conky/Conky.desktop > ${directories_array[3]}Conky.desktop"
				echo "Copying: /etc/hackutils/conky/.conkyrc > ${directories_array[4]}.conkyrc"
				echo "Copying: /etc/hackutils/conky/internet_test.sh > ${directories_array[5]}"

				cat /etc/hackutils/conky/Conky.desktop | sed "s|\$HOME/|${directories_array[4]}|g" > ${directories_array[3]}Conky.desktop
				cat /etc/hackutils/conky/.conkyrc | sed "s|\$HOME/|${directories_array[5]}|g" | sed "s|\$interface|${ifaces_array[$selection]}|g" > ${directories_array[4]}.conkyrc

				cp /etc/hackutils/conky/internet_test.sh ${directories_array[5]}

			;;

			conf*)
				echo -e $LIGHTYELLOW"conf"$END")" "Modify Hack_utils config file"
				echo ""

				sudo nano /etc/hackutils/hack_utils.conf

				ignore_continue_enter=true

			;;

			1)
				echo -e $LIGHTYELLOW"1"$END")" "Ping"
				echo ""

				echo -e "From which interface you want to throw the ping?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"					

				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi
				
				echo -e "Which address you want to ping?"
				echo -ne $BLINK" >  "$END" IP: "$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""

				ip_checker $ip_address

				echo -e $CYAN$BOLD" > Pinging to $ip_address..."$END
				echo ""

				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""

				ping -I ${ifaces_array[$selection]} $ip_address

				break
				;;

			2)
				echo -e $LIGHTYELLOW"2"$END")" "Try internet connection"
				echo ""

				echo -e $CYAN$BOLD" > Pinging to Google..."$END
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


				echo -e "From which interface you want to throw the ping?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				echo -e "Which address you want to traceroute?"
				echo -ne $BLINK" >  "$END" IP: "$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""

				ip_checker $ip_address

				echo -e $CYAN$BOLD" > Traceroute: Default"$END
				traceroute --queries=3 --max-hops=15 --interface=${ifaces_array[$selection]} $ip_address

				echo ""
				echo -e $CYAN$BOLD" > Traceroute: ICMP probes"$END
				traceroute --icmp --queries=3 --max-hops=15 --interface=${ifaces_array[$selection]} $ip_address
				
				echo ""
				echo -e $CYAN$BOLD" > Traceroute: TCP probes"$END
				traceroute --tcp --queries=3 --max-hops=15 --interface=${ifaces_array[$selection]} $ip_address
				
				echo ""
				echo -e $CYAN$BOLD" > Traceroute: UDP probes"$END
				traceroute --udp --queries=3 --max-hops=15 --interface=${ifaces_array[$selection]} $ip_address

				;;

			4)
				echo -e $LIGHTYELLOW"4"$END")" "Whois"
				echo ""

				echo -e "Enter the IP address or domain to lookup:"
				echo -ne $BLINK" >  "$END" IP / Domain: "$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
				echo ""
				echo ""
				echo ""

				#Esto se comenta para hacer el whois a nombres de dominio, no solo a IPs
				#ip_checker $ip_address

				echo -e $CYAN$BOLD"    ____  ____  __  ______    _____   __   _       ____  ______  _________"$END
				echo -e $CYAN$BOLD"   / __ \/ __ \/  |/  /   |  /  _/ | / /  | |     / / / / / __ \/  _/ ___/"$END
				echo -e $CYAN$BOLD"  / / / / / / / /|_/ / /| |  / //  |/ /   | | /| / / /_/ / / / // / \__ \   "$END
				echo -e $CYAN$BOLD" / /_/ / /_/ / /  / / ___ |_/ // /|  /    | |/ |/ / __  / /_/ // / ___/ / "$END
				echo -e $CYAN$BOLD"/_____/\____/_/  /_/_/  |_/___/_/ |_/     |__/|__/_/ /_/\____/___//____/  "$END


				whois $ip_address

				;;

			5)
				echo -e $LIGHTYELLOW"5"$END")" "Hops to gateway"
				echo ""

				echo -e "From which interface you want to reach the gateway?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				gateway_ip=`ip route list | grep $selection | grep default | cut -f 3 -d " " | uniq`

				if [ "$gateway_ip" == '' ];
				then
					echo -e $RED"The interface is not connected to the network."$END
				else
					output=`traceroute --queries=3 --max-hops=10 --interface=${ifaces_array[$selection]} $gateway_ip`

					hops=`echo -e $output "\b" | grep -o "[0-9] $gateway_ip" | cut -f1 -d" " | tail -n1`

					echo -e $CYAN$BOLD" > You have $hops hop(s) until reach your default gateway"$END
					echo ""

					## s --> sustitucion / nueva linea, pero con & se aÃ±ade, no se sustituye. La g pra todas las coincidencias de " [0-9] "
					## El segundo sed aÃ±ade a partir del 4 caracter un espacio de mas, y lo hace para todas las lineas entre la 2 y la 9.
					echo $output | sed -e 's/ [0-9] / \n &/g' | sed -e '2,9 s/./& /4'
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

				ip_address=`curl icanhazip.com`

				echo -e $CYAN$BOLD" > PUBLIC IP"$END
				echo -e $UNDERYELLOW$BLACK"$ip_address"$END
				echo ""
				
				whois $ip_address | grep -E 'country:|netname:|descr:|adress:|origin:'

				;;

			8)
				echo -e $LIGHTYELLOW"8"$END")" "Traffic monitoring (iptraf)"
				echo ""

				iptraf-ng
				
				ignore_continue_enter=true

				;;

			9)
				echo -e $LIGHTYELLOW"9"$END")" "Traffic by interface"
				echo ""

				echo -e "In which interface you want to monitor the traffic?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi
			

				interface=$selection

				echo -e "What program you want to use?"

				echo -ne " " $LIGHTYELLOW"m"$END")"
				printf "$CYAN$BOLD %-11s $END" "More info"; echo ""

				options_selector $number_of_bandwith_interface_program "bandwith_interface_programs_array"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END

				if [[ $selection == "m" ]];
				then
					echo ""

					echo -ne " " $LIGHTYELLOW"1"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "slurm" "Simple live graphical"; echo ""
					echo -ne " " $LIGHTYELLOW"2"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "iftop" "Bytes Rx and Tx in live to specific destination"; echo ""
					echo -ne " " $LIGHTYELLOW"3"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "speedometer" "Simple live graphical"; echo ""
					echo -ne " " $LIGHTYELLOW"4"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "tcptrack" "Speed by each open connections"; echo ""
					echo -ne " " $LIGHTYELLOW"5"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "ifstat" "Prints every 0.5 sec the bytes Rx and Tx. Nice to capture traffic peaks."; echo ""
					echo -ne " " $LIGHTYELLOW"6"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "vnstat" "Monitor the bytes Rx and Tx. Can choose in live or background mode."; echo ""
					echo -ne " " $LIGHTYELLOW"7"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "nload" "Monitor the traffic in all interfaces (Use the arrows to switch). The graph is used to monitor downloads or uploads over a long period of time (average 30 seconds)."; echo ""
					echo -ne " " $LIGHTYELLOW"8"$END")"
					printf "$CYAN$BOLD %-11s $END >> %-1s" "bwm-ng" "Simple monitor traffic live"; echo ""
					echo ""

					echo -ne " " $LIGHTYELLOW"0"$END")"
					printf "$CYAN$BOLD %-11s $END" "Exit"; echo ""
					echo ""

					echo -e "If you have any problem with the programs, check if they are installed with the option "$LIGHTYELLOW"chckdep"$END
					echo ""

					echo "Type an option:"
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				fi

				response_checker "$selection" "$number_of_bandwith_interface_program"

				## If selection is 0, exit this option		
				if [[ $selection == "exit" ]]; then break; fi

				program_bandwidth_interface=$selection

				if [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "slurm" ]];
				then
					slurm -i ${ifaces_array[$interface]} -z

					ignore_continue_enter=true

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "iftop" ]];
				then
					iftop -i ${ifaces_array[$interface]}

					ignore_continue_enter=true

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "speedometer" ]];
				then
					speedometer -r ${ifaces_array[$interface]} -t ${ifaces_array[$interface]}

					ignore_continue_enter=true

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "tcptrack" ]];
				then
					tcptrack -i ${ifaces_array[$interface]}

					ignore_continue_enter=true

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "ifstat" ]];
				then
					ifstat -t -i ${ifaces_array[$interface]} 0.5

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "vnstat" ]];
				then
					echo ""
					echo "Select an option to do:"

					echo -e " " $LIGHTYELLOW"start"$END")" "Start vnstat in background"
					echo -e " " $LIGHTYELLOW" stop"$END")" "Stop vnstat in background"
					echo -e " " $LIGHTYELLOW" view"$END")" "View the last report"
					echo -e " " $LIGHTYELLOW" live"$END")" "View the traffic Rx and Tx in live"
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
							echo -e $CYAN$BOLD" > INITIATING THE SERVICE VNSTAT..."$END

							systemctl start vnstat

							systemctl status vnstat

							;;
						stop)
							echo -e $CYAN$BOLD" > STOPING THE SERVICE VNSTAT..."$END

							systemctl stop vnstat

							systemctl status vnstat

							echo ""
							echo -e $CYAN$BOLD" > REPORT"$END
							vnstat

							;;
						view)
							echo -e $CYAN$BOLD" > LAST REPORT"$END
							vnstat

							;;
						live)
							vnstat --live --iface ${ifaces_array[$interface]}

							;;
						calc)
							echo -e $CYAN$BOLD" > CALCULATING THE TRAFFIC..."$END

							command_for_interfaces "vnstat --traffic --iface " ""

							;;
						0)
							valid_option=true

							;;
						*)
							invalidoption=true
							ignore_continue_enter=false	

							;;
					esac
					

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "nload" ]];
				then
					nload -a 30

					ignore_continue_enter=true

				elif [[ ${bandwith_interface_programs_array[$program_bandwidth_interface]} == "bwm-ng" ]];
				then
					bwm-ng bwm-ng --allif 2

					ignore_continue_enter=true

				fi

				;;

			10)
				echo -e $LIGHTYELLOW"10"$END")" "Check remote port status"
				echo ""

				echo -e "From which interface yo want to check de remote port status?"
				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_interfaces"
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				echo -e "Type the host and the port."
				echo -ne $BLINK" >  "$END" IP: "$END$LIGHTYELLOW ; read ip_address ; echo -ne "" $END

				ip_checker $ip_address

				echo -ne $BLINK"> "$END"Port: "$END$LIGHTYELLOW ; read port ; echo -ne "\r" $END
				echo ""

				telnet_output=`nmap $ip_address -p $port | grep $port | cut -f 2 -d " "`

				echo ""
				echo -e $CYAN$BOLD" > PORT STATUS"$END

				if [[ "$telnet_output" == "open" ]];
				then
					echo -ne "$ip_address:$port" $END">>" $UNDERGREEN$BLACK "OPEN" $END

				elif [[ "$telnet_output" == "closed" ]];
				then
					echo -ne "$ip_address" "$port" $UNDERRED$WHITE "CLOSED" $END

				else
					echo -ne "$ip_address" "$port" $UNDERYELLOW$BLACK "$telnet_output" $END
				fi

				echo ""
				echo ""
				echo ""

				;;

			11)
				echo -e $LIGHTYELLOW"11"$END")" "Ports in use"
				echo ""

				echo -e "Enter the port number, IP address or program name. Press "$LIGHTYELLOW"ENTER"$END" to view all connections:"
				echo -ne $BLINK"> "$END"Search: "$LIGHTYELLOW ; read port ; echo -ne "" $END
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
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				program_web_terminals=$selection

				if [[ ${web_terminals_array[$program_web_terminals]} == "cat" ]];
				then
					lynx -accept_all_cookies -dump "https://es.adminsub.net/tcp-udp-port-finder/"$port > ${directories_array[2]}lynx_ports.txt

					total_lines=`wc -l ${directories_array[2]}lynx_ports.txt | cut -c1-3`
					lines_below=`cat -n ${directories_array[2]}lynx_ports.txt | cut -c4-100 | grep "squedas Recientes" | cut -c1-3`
					lines_above=`cat -n ${directories_array[2]}lynx_ports.txt | cut -c4-100 | grep "Buscar los resultados de" | cut -c1-3`

					lines_below=$((lines_below - 1))
					lines_above=$(((lines_above + 1) * -1))

					cat ${directories_array[2]}lynx_ports.txt | head -n $lines_below | tac | head -n $lines_above | tac

				elif [[ ${web_terminals_array[$program_web_terminals]} == "elinks" ]];
				then
					elinks "https://es.adminsub.net/tcp-udp-port-finder/"$port

					ignore_continue_enter=true

				elif [[ ${web_terminals_array[$program_web_terminals]} == "lynx" ]];
				then
					lynx -accept_all_cookies "https://es.adminsub.net/tcp-udp-port-finder/"$port

					ignore_continue_enter=true
				fi

				;;

			13)
				echo -e $LIGHTYELLOW"13"$END")" "Firewall rules (iptables)"
				echo ""
				echo ""
				echo ""

				echo -e $CYAN$BOLD" > List of rules"$END
				echo ""

				iptables -L
				
				echo ""
				echo -e $CYAN$BOLD" > Rules"$END
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

				echo -e $CYAN$BOLD" > AUTONOMOUS SYSTEM"$END
				whois -h whois.cymru.com -- -v "$ip_address"

				echo ""
				echo ""
				echo ""
				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""

				echo -e $CYAN$BOLD" > BLACKLISTS"$END
				bash /etc/hackutils/bl.sh $ip_address

				;;

			16)
				echo -e $LIGHTYELLOW"16"$END")" "Internet speed test"
				echo ""

				echo -e $CYAN$BOLD" > INITIATING INTERNET SPEED TEST"$END
				echo ""

				waitFunction "5" "0.20"

				output=`speedtest | sed 's/$/#/g'`

				waitFunction "5" "0.20"
			
				echo -e $output | sed 's/#/\n/g' | sed 's/Testing/\nTesting/g' | sed ''/Download/s//`printf "\033[31mâ†“Download\033[0m"`/'' | sed ''/Upload/s//`printf "\033[32mâ†‘Upload\033[0m"`/'' | sed 's/â†“Download/ â†“ Download/g' | sed 's/â†‘Upload/ â†‘ Upload/g' 

				;;

			advif*)
				echo -e $LIGHTYELLOW"advif"$END")" "Advanced interface info (nmcli)"
				echo ""

				#Function               First part of the command       Second part of the command
				#command_for_interfaces "ifconfig "                     ""
				command_for_interfaces "nmcli device show " ""

				;;

			sniff*)
				echo -e $LIGHTYELLOW"sniff"$END")" "Sniff packets"
				echo ""

				echo -e "From which interface you want to sniff the network?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END

				response_checker "$selection" "$number_of_interfaces"
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				filters=""

				while [ "$filters" == "" ];
				do
					echo ""
					echo -e "Type the filters for tcpdump (Press enter = ignore. Type "$LIGHTYELLOW"h"$END" = view some tcpdump help)"
					echo -ne $BLINK" > Filters: "$END$LIGHTYELLOW ; read filters ; echo -ne "" $END

					if [[ "$filters" == "h" ]];
					then
						echo ""
						echo -e $CYAN$BOLD "EXAMPLES" $END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"port 80"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"src port 80"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"not port 80"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"not portrange 50-150"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"src host 192.168.2.10"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"dst host 192.168.2.10"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"host 192.168.2.10"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"host 192.168.2.1 and port 443"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"less 850 and src host 192.168.2.10"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"greater 500 and less 1200"$END
						echo -e "tcpdump -i ${ifaces_array[$selection]} "$LIGHTYELLOW"greater 100 and (src host google.com or src host microsoft.com)"$END
						echo ""
						echo -e $CYAN$BOLD "FLAGS" $END
						echo -e $LIGHTYELLOW"[S]"$END" - SYN. The first step to establish the connection."
						echo -e $LIGHTYELLOW"[F]"$END" - END. Termination of the connection."
						echo -e $LIGHTYELLOW"[.]"$END" - ACK. Acknowledgement package received successfully."
						echo -e $LIGHTYELLOW"[P]"$END" - PUSH. Tells the receiver to process packets instead of buffering them."
						echo -e $LIGHTYELLOW"[R]"$END" - RST. Communication stopped."
						echo -e $LIGHTYELLOW"[F.]"$END" - FIN-ACK. Flags can include more than one value, as in this example. Acknowledgement of the termination of the connection."

						filters=""

					elif [[ "$filters" == "" ]];
					then
						break

					fi
				done

				echo ""
				echo ""
				echo -e $CYAN$BOLD " > SNIFFING PACKETS IN ${ifaces_array[$selection]}" $END
				echo ""
				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""
				tcpdump -i ${ifaces_array[$selection]} $filters

				;;

			pping*)
				echo -e $LIGHTYELLOW"advping"$END")" "Ping (personalized)"
				echo ""

				echo -e "From which interface you want to throw the ping?"

				options_selector $number_of_interfaces "ifaces_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END

				response_checker "$selection" "$number_of_interfaces"
				
				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

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
				echo -e $CYAN$BOLD $pping_command $ip_address $END
				echo ""

				echo -e $UNDERRED$BLACK"Ctrl+C to cancel"$END
				echo ""


				$pping_command $ip_address

				;;

			ovpn*)
				echo -e $LIGHTYELLOW"ovpn"$END")" "Connect to a OVPN server"
				echo ""

				if [[ $number_of_ovpns_active > "0" ]];
				then
					echo "There is alredy active connections. Do you want to finish it?"

					options_selector $number_of_ovpns_active "ovpns_active_array"

					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
					echo ""

					response_checker "$selection" "$number_of_ovpns_active"

					## If selection is 0, exit this option		
					if [[ $selection == "exit" ]]; then break; fi

					pid=`ps aux | grep ${ovpns_active_array[$selection]} | head -n1 | tr -s [[:space:]] | cut -f2 -d" "`

					echo -e $CYAN$BOLD" > Killing the process $pid corresponding to the process ${ovpns_active_array[$selection]}"$END

					kill $pid
					
					echo ""
					echo ""

				elif [[ $ovpns_extracted == '' ]];
				then
					echo "There is no OVPN profiles configured in the system."
					echo "You need to export your OVPN profiles from your OVPN Server to the path $HOME/.secret/ovpns/ of this OVPN client and then rerun Hack_Utils."

					exit 0
				else
					:
				fi

				echo "Select the VPN profile you want to connect to (profiles saves in ${directories_array[0]})"
				options_selector $number_of_ovpns "ovpns_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				response_checker "$selection" "$number_of_ovpns"

				## If selection is 0, exit this option		
				if [[ $selection == "exit" ]]; then break; fi

				echo ""
				echo -ne $CYAN$BOLD" > Connecting to VPN with profile ${ovpns_array[$selection]}\n"$END

				sudo openvpn --config ${directories_array[0]}${ovpns_array[$selection]} 2> /dev/null &

				waitFunction "6" "0.10"

			;;

			cliweb*)
				echo -e $LIGHTYELLOW"cliweb"$END")" "Web in CLI (elinks)"
				echo ""

				echo -e "Type the URL of the webpage. Press "$UNDERRED$BLACK"q or Ctrl+C to exit elinks"$END
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read url ; echo -ne "" $END

				elinks $url

				ignore_continue_enter=true

			;;

			macman*)
				echo -e $LIGHTYELLOW"macman"$END")" "MAC manufacturer"
				echo ""

				echo -e "Type the MAC (required internet):"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read mac ; echo -ne "" $END

				mac=`echo $mac | tr '[a-z]' '[A-Z]' | tr -d ":" | tr -d "." | tr -d [:space:] | cut -c 1-6`
				echo ""
				echo ""

				echo "> VENDOR"
				output=`curl https://gist.githubusercontent.com/aallan/b4bb86db86079509e6159810ae9bd3e4/raw/846ae1b646ab0f4d646af9115e47365f4118e5f6/mac-vendor.txt | grep $mac`

				echo -e $CYAN$BOLD$output$END

			;;

			anon*)

				echo -e $LIGHTYELLOW"anon"$END")" "Anonymizer"
				echo ""

				while true;
				do
					torctlstatus=`torctl status | grep -w "tor service is:" | rev | cut -f1 -d" " | rev`
					anonsurfstatus=`sudo anonsurf status | grep -w "Active:" | tr -s [:space:] ":" | cut -f3 -d":"`
					nordvpnstatus=`nordvpn status | grep -w "Status:" | rev | cut -f1 -d" " | rev`

					options_array=("IP TOR anonymizer for Arch Linux (torctl) (activate / deactivate): $torctlstatus" "IP TOR anonymizer for Kali Linux (anonsurf) (activate / deactivate): $anonsurfstatus" "Change MAC address" "Restore MAC address" "NordVPN (activate / deactivate): $nordvpnstatus")
					options_selector 5 "options_array"

					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read option ; echo -ne "" $END
					echo ""

					case $option in
						1)
							clear

							#torctlstatus=`torctl status | grep -ow "tor service is: inactive"`

							if [[ $torctlstatus == 'inactive' ]];
							then
								echo -e $GREEN"\n------------- Activating TORCTL -------------\n"$END
								sudo systemctl start tor
							else
								echo -e $RED"\n------------- Deactivating TORCTL -------------\n"$END
								sudo systemctl stop tor
							fi

							;;

						2)
							clear

							path=`which anonsurf`

							if [[ $path == '' ]];
							then
								echo -e "																																																										"
								echo -e $UNDERRED$BLACK"Anonsurf not installed."$END
							
							else
								if [[ $anonsurfstatus == 'inactive' ]];
								then
									echo -e $GREEN"\n------------- Activating ANONSURF -------------\n"$END
									anonsurf start
								else
									echo -e $RED"\n------------- Deactivating ANONSURF -------------\n"$END
									anonsurf stop
								fi
							fi

							;;

						3)
							clear

							iface=`ip addr | awk '/state UP/ {print $2}' | sed 's/.$//'`

							ip link set $iface down
							output=`macchanger --another $iface`
							ip link set $iface up

							#echo -e $output | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
							echo -e $CYAN$BOLD"\n"$output | sed 's/) /)\n/g'; echo -e $END

							#valid_option=true

							;;

						4)
							clear
	
							iface=`ip addr | awk '/state UP/ {print $2}' | sed 's/.$//'`
	
							ip link set $iface down
							output=`macchanger --permanent $iface`
							ip link set $iface up
	
							#echo -e $output | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
							echo -e $CYAN$BOLD"\n"$output | sed 's/) /)\n/g'; echo -e $END

							;;

						5)
							clear

							path=`which nordvpn`

							if [[ $path == '' ]];
							then
								echo -e "																																																										"
								echo -e $UNDERRED$BLACK"NordVPN not installed."$END
							
							else
								if [[ $nordvpnstatus == 'Disconnected' ]];
								then
									echo -e $GREEN"\n------------- Connecting to NordVPN -------------\n"$END
	
										echo -e $CYAN$BOLD
										nordvpn countries
										echo -e $END
	
										echo -e "\nType the country you want to connect to:"
										echo -ne $BLINK" > "$END$LIGHTYELLOW ; read country ; echo -ne "" $END
										echo ""
	
										nordvpn connect $country
	
										echo -e $CYAN$BOLD
										nordvpn status
										echo -e $END
									else
										echo -e $RED"\n------------- Disconnecting from NordVPN -------------\n"$END
	
										nordvpn disconnect
	
										echo -e $CYAN$BOLD
										nordvpn status
										echo -e $END
								fi
							fi

							;;

						0)
							ignore_continue_enter=true
							break

							;;

						*)
							invalidoption=true
							ignore_continue_enter=false	

							;;
					esac
				done
				;;
				

			malware*)
				echo -e $LIGHTYELLOW"malware"$END")" "Cyber threats search (Malware Bazaar API)"
				echo ""

				echo -e "Enter the hash MD5, SHA1 or SHA256 of the threat (Example):"
				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read hash ; echo -ne "" $END
				echo ""


				wget --post-data "query=get_info&hash="$hash https://mb-api.abuse.ch/api/v1/ --output-document=${directories_array[2]}malware_bazaar_tmp.json
				sed 's/ANY.RUN/ANYRUN/g' ${directories_array[2]}malware_bazaar_tmp.json > ${directories_array[2]}malware_bazaar.json
				rm ${directories_array[2]}malware_bazaar_tmp.json

				if [[ $(cat ${directories_array[2]}malware_bazaar.json | jq -r .query_status) != "ok" ]];
				then
					echo -e $RED$BOLD "Hash not found in Malware Bazaar"
					echo ""

					break
				fi

				files_array=( "${directories_array[2]}malware_bazaar_tmp.json" "${directories_array[2]}malware_bazaar.json" "${directories_array[2]}triage_signatures_raw.txt" "${directories_array[2]}triage_scores_raw.txt" )

				for file in "${files_array[@]}"
				do
					touch $file
					chmod 766 $file
				done

				echo -e $CYAN$BOLD " > HASHES" $END
				echo -ne "SHA256: " $CYAN$BOLD; jq -r '.data[] | .sha256_hash' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "SHA3_384: " $CYAN$BOLD; jq -r '.data[] | .sha3_384_hash' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "SHA1: " $CYAN$BOLD; jq -r '.data[] | .sha1_hash' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "MD5: " $CYAN$BOLD; jq -r '.data[] | .md5_hash' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo ""
				echo -e $CYAN$BOLD " > FILE INFO" $END
				echo -ne "First seen: " $CYAN$BOLD; jq -r '.data[] | .first_seen' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Last seen: " $CYAN$BOLD; jq -r '.data[] | .last_seen' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "File name: " $CYAN$BOLD; jq -r '.data[] | .file_name' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "File size: " $CYAN$BOLD; output=`jq -r '.data[] | .file_size' ${directories_array[2]}malware_bazaar.json`; echo -ne "0"; echo "scale=3; $output / 1024 /1024" | bc -l | sed "s/$/ MB/g"; echo -ne $END
				echo -ne "File type mime: " $CYAN$BOLD; jq -r '.data[] | .file_type_mime' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "File type: " $CYAN$BOLD; jq -r '.data[] | .file_type' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Reporter: " $CYAN$BOLD; jq -r '.data[] | .reporter' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Origin country: " $CYAN$BOLD; jq -r '.data[] | .origin_country' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Signature: " $CYAN$BOLD; jq -r '.data[] | .signature' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Code sign: " $CYAN$BOLD; jq -r '.data[] | .code_sign' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Delivery method: " $CYAN$BOLD; jq -r '.data[] | .delivery_method' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Comment: " $CYAN$BOLD; jq -r '.data[] | .comment' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo ""
				echo -e $CYAN$BOLD " > ANALYSIS" $END
				echo -e $CYAN$BOLD "any.run" $END
				echo -ne "Detection: " $CYAN$BOLD; jq -r '.data[].vendor_intel.ANYRUN[].verdict' ${directories_array[2]}malware_bazaar.json | sed '/Malicious[[:space:]]activity/s//'$(printf "\e[31mMaliciousactivity\033[0m")'/' |  sed 's/Maliciousactivity/Malicious activity/g'; echo -ne $END;
				echo -ne "URL: " $BLUE$BOLD; jq -r '.data[].vendor_intel.ANYRUN[].analysis_url' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -e $CYAN$BOLD "cape" $END
				echo -ne "Detection: " $CYAN$BOLD; jq -r '.data[].vendor_intel.CAPE.detection' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "URL: " $BLUE$BOLD; jq -r '.data[].vendor_intel.CAPE.link' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -e $CYAN$BOLD "tria.ge" $END
				echo -ne "Malware family: " $CYAN$BOLD; jq -r '.data[].vendor_intel.Triage.malware_family' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Score: " $CYAN$BOLD; score=`jq -r '.data[].vendor_intel.Triage.score' ${directories_array[2]}malware_bazaar.json`; malware_score_checker $score; echo -ne $END
				echo -ne "URL: " $BLUE$BOLD; jq -r '.data[].vendor_intel.Triage.link' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -e "Signatures: " 
				echo ""

				jq -r '.data[].vendor_intel.Triage.signatures[].signature' ${directories_array[2]}malware_bazaar.json > ${directories_array[2]}triage_signatures_raw.txt
				jq -r '.data[].vendor_intel.Triage.signatures[].score' ${directories_array[2]}malware_bazaar.json > ${directories_array[2]}triage_scores_raw.txt

				counter=1
				ladder="  "

				echo -ne $CYAN$BOLD"$ladder""Init>"$END

				while IFS= read -r line
				do
					score=`cat ${directories_array[2]}triage_scores_raw.txt | sed -n $counter\p`

					echo -e "â” "
					echo -ne "$ladder""â”Œâ”€â”€â”€â”€â”´â”€â•¢ "
					echo -e $CYAN$BOLD $line $END
					echo -ne "$ladder""â”œâ”€â•¢ Score: "

					malware_score_checker $score


					echo -e "$ladder""â”‚"
					echo -ne "$ladder""â””â”€â”€â”€>â”€â”€"

					$((counter++)) 2> /dev/null
					ladder+="  "

					sleep 0.1

				done < ${directories_array[2]}triage_signatures_raw.txt

				echo -e $CYAN$BOLD"\bEnd<" $END
				echo ""
				echo -e $CYAN$BOLD "ReversingLabs" $END
				echo -ne "Threat name: " $CYAN$BOLD; jq -r '.data[].vendor_intel.ReversingLabs.threat_name' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Status: " $CYAN$BOLD; jq -r '.data[].vendor_intel.ReversingLabs.status' ${directories_array[2]}malware_bazaar.json | sed '/MALICIOUS/s//'$(printf "\e[31mMALICIOUS\033[0m")'/'; echo -ne $END;
				echo -ne "First seen: " $CYAN$BOLD; jq -r '.data[].vendor_intel.ReversingLabs.first_seen' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Scanner count: " $CYAN$BOLD; jq -r '.data[].vendor_intel.ReversingLabs.scanner_count' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Scanner match: " $CYAN$BOLD; jq -r '.data[].vendor_intel.ReversingLabs.scanner_match' ${directories_array[2]}malware_bazaar.json; echo -ne $END
				echo -ne "Scanner score: " $CYAN$BOLD; output=`jq -r '.data[].vendor_intel.ReversingLabs.scanner_percent' ${directories_array[2]}malware_bazaar.json`; output=`echo "scale=0; $output / 10" | bc -l`; malware_score_checker $output; echo -ne $END
				echo -e $CYAN$BOLD "UnpacMe" $END
				echo -ne "URL: " $BLUE$BOLD; jq -r '.data[].vendor_intel.UnpacMe[].link' ${directories_array[2]}malware_bazaar.json | uniq; echo -ne $END

				for file in "${files_array[@]}"
				do
					rm $file
				done

				;;

			conv*)
				echo -e $LIGHTYELLOW"conv"$END")" "Hex / Base64 converter"
				echo ""

				options_array=( "Base64" "Hex" "Binary" )
				options_selector 3 "options_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				echo $selection

				response_checker "$selection" "3"

				## If selection is 0, exit this option
				if [[ $selection == "0" ]]; then break; fi

				string=""

				case $selection in
					1)
						while true;
						do
							clear 

							if [[ $string == "exit" ]];
							then
								ignore_continue_enter=true
								break
							fi
	
							echo -e $LIGHTYELLOW"conv"$END")" "Base64 converter"
							echo ""
							
							echo -e $CYAN$BOLD" > DECODE"$END
							echo $string | base64 --decode 2> /dev/null 
							
							echo ""
							echo ""
							
							echo -e $CYAN$BOLD" > ENCODE "$END
							echo $string | base64 | sed '/^Cg==$/d'
							
							echo ""
							echo ""
							echo ""

							echo -e "Type the string you want to encode / decode (To return to the main menu type "$LIGHTYELLOW"exit"$END"):"
							echo -ne $BLINK" > "$END"Text: "$LIGHTYELLOW ; read string ; echo -ne "" $END

						done
						;;

					2)
						while true;
						do
							clear 

							if [[ $string == "exit" ]];
							then
								ignore_continue_enter=true
								break
							fi
	
							echo -e $LIGHTYELLOW"conv"$END")" "Hex converter"
							echo ""
							
							echo -e $CYAN$BOLD" > DECODE"$END
							echo $string | xxd -p -r
							
							echo ""
							echo ""
							
							echo -e $CYAN$BOLD" > ENCODE "$END
							echo $string | xxd -ps | sed '/^0a$/d' 
							echo ""
							echo ""

							echo -e $CYAN$BOLD" > HEXDUMP "$END
							echo $string | xxd | sed '/^00000000: 0a                                       .$/d'

							echo ""
							echo ""
							echo ""

							echo -e "Type the string you want to encode / decode (To return to the main menu type "$LIGHTYELLOW"exit"$END"):"
							echo -ne $BLINK" > "$END"Text: "$LIGHTYELLOW ; read string ; echo -ne "" $END

						done

						;;

					3)
						while true;
						do
							clear 

							if [[ $string == "exit" ]];
							then
								ignore_continue_enter=true
								break
							fi
	
							echo -e $LIGHTYELLOW"conv"$END")" "Binary converter"
							echo ""
							
							echo -e $CYAN$BOLD" > ENCODE"$END
							output=`echo $string | xxd -b -d | sed 's/  /:/g' | sed 's/: /:/g' | cut -f2 -d":"`  
							echo $output | sed '/^00001010$/d'
							
							echo ""
							echo ""
							echo ""

							echo -e $CYAN$BOLD" > BINARYDUMP "$END
							echo $string | xxd -b -d | sed '/^00000000: 00001010                                               .$/d'
							echo ""
							echo ""

							echo -e "Type the string you want to encode / decode (To return to the main menu type "$LIGHTYELLOW"exit"$END"):"
							echo -ne $BLINK" > "$END"Text: "$LIGHTYELLOW ; read string ; echo -ne "" $END

						done

						;;


					0)
						ignore_continue_enter=true
						break

						;;
					*)
						invalidoption=false
						ignore_continue_enter=false	

						;;
				esac

				;;

			sshtun*)
				echo -e $LIGHTYELLOW"sshtun"$END")" "SSH tunneling"
				echo ""

				echo "nothing... 4 now..."

				;;

			fkap*)
				echo -e $LIGHTYELLOW"fkap"$END")" "Fake Access Point: Evil twin"
				echo ""

				echo -e "What you want to do?"
				
				options_array=("Create an Evil Twin" "View the backgrounded Evil Twin")
				options_selector 2 "options_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				case $selection in
					1)

						echo -e "From which wireless interface you want to start the Evil Twin?"

						options_selector $number_of_wlan_interfaces "wlan_ifaces_array"

						echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
						echo ""

						response_checker "$selection" "$number_of_interfaces"					

						## If selection is 0, exit this option
						if [[ $selection == "exit" ]]; then break; fi
				
						selection_interface=$selection
		
						echo -e "What IP address do you want the Evil Twin to have? This address wil be the default GW for the clients."
						echo -e "Press "$LIGHTYELLOW"ENTER"$END" to leave by default ("$CYAN$BOLD"10.10.0.1"$END")."
						echo -ne $BLINK" >  "$END" IP: "$LIGHTYELLOW ; read ip_address ; echo -ne "" $END
						echo ""

						if [[ -z $ip_address ]];
						then
							ip_address="10.10.0.1"
		
						else
							ip_checker $ip_address
		
						fi

						echo -e "Enter the SSID name for the network:"
						echo -ne $BLINK" > "$END$LIGHTYELLOW ; read ssid ; echo -ne "" $END
						echo ""
		
						echo -e "Enter the password to access the network."
						echo -e "Press "$LIGHTYELLOW"ENTER"$END" to create an open AP:"
						echo -ne $BLINK" > "$END$LIGHTYELLOW ; read passwd ; echo -ne "" $END
						echo ""

						echo -e "Which interface you want to use for post-routing (NAT to internet)?"
		
						options_selector $number_of_interfaces "ifaces_array"
		
						echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
						echo ""

						response_checker "$selection" "$number_of_interfaces"					
		
						## If selection is 0, exit this option
						if [[ $selection == "exit" ]]; then break; fi

						selection_interface_nat=$selection
		
						time=0.1
				
						active_sessions=`tmux list-sessions | egrep "FKAP-[0-9]{0,1}" | cut -f1 -d":"`
				
						for session in $active_sessions:
						do
							tmux kill-session -t $session && sleep $time
				
						done
				
						tmux new-session -d -t FKAP && sleep $time
						tmux split-window -h && sleep $time
						#tmux resize-pane -t 1 -L 12 && sleep $time
						
						tmux select-pane -t 1 && sleep $time
						tmux send-keys "sudo bash /etc/hackutils/arp_table.sh 2> /dev/null" C-m && sleep $time

						tmux select-pane -t 0 && sleep $time
						tmux send-keys "sudo bash /etc/hackutils/fkap.sh ${wlan_ifaces_array[$selection_interface]} $ip_address $ssid $passwd ${ifaces_array[$selection_interface_nat]} 2> /dev/null" C-m && sleep $time
						#tmux list-sessions

						echo -e $CYAN$BOLD" > The Evil Twin can be run in the background by pressing "$LIGHTYELLOW"Ctrl + b --> d (detached)"$END
						waitFunction "5" "0.40"
						
						tmux attach-session -t FKAP

						echo -e $CYAN$BOLD" > THE EVIL TWIN IS WORKING ON BACKGROUND IN TMUX"$END
					;;

					2)
						echo "Active tmux sessions:"
						tmux list-sessions | grep "FKAP"
						tmux attach-session -t FKAP

						echo ""
					;;
					
					0)
						ignore_continue_enter=true

						break
					;;

					*)
						invalidoption=true
						ignore_continue_enter=false	
					;;
	
				esac
			;;

			dwa*)
				echo -e $LIGHTYELLOW"dwa"$END")" "Deauth Wireless Attack"
				echo ""

				echo -e "What you want to do?"
				
				options_array=("Attack a WiFi network" "View the backgrounded attack" "End the backgrounded attack")
				options_selector 3 "options_array"

				echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
				echo ""

				## If selection is 0, exit this option
				if [[ $selection == "exit" ]]; then break; fi

				case $selection in
					1)

						echo -e "From which interface you want to make the attack"

						options_selector $number_of_wlan_interfaces "wlan_ifaces_array"

						echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
						echo ""

						response_checker "$selection" "$number_of_wlan_interfaces"

						## If selection is 0, exit this option
						if [[ $selection == "exit" ]]; then break; fi
		
						time=0.1
		
						active_sessions=`tmux list-sessions | egrep "DWA-[0-9]{0,1}" | cut -f1 -d":"`
		
						for session in $active_sessions:
						do
							tmux kill-session -t $session && sleep $time
		
						done
		
						tmux new-session -d -t DWA && sleep $time
						tmux split-window -h && sleep $time
						#tmux resize-pane -t 1 -L 12 && sleep $time

						tmux select-pane -t 0 && sleep $time
						tmux send-keys "sudo bash /etc/hackutils/dwa.sh ${wlan_ifaces_array[$selection]} 2> /dev/null" C-m && sleep $time
						
						#tmux list-sessions
						tmux attach-session -t DWA
		
						echo -e $CYAN$BOLD" > THE ATTACK IS WORKING ON BACKGROUND IN TMUX"$END
					;;

					2)
						echo "Active tmux sessions:"
						tmux list-sessions | grep "DWA"
						tmux attach-session -t DWA

						echo ""
					;;

					3)
						echo "Killing tmux session..."
						#tmux kill-session -t DWA
						
						for interface in ${wlan_ifaces_array[@]}
						do
							output=`iwconfig $interface | grep "Mode:Monitor" | egrep -o "wlan[0-9]{1,2}"`

							if [[ -n "$output" ]];
							then
								echo "Setting the $interface as managed mode..."
								ip link set $interface down
								iwconfig $interface mode managed
								ip link set $interface up
							fi
		
						done
					;;


					0)
						ignore_continue_enter=true

						break
					;;

					*)
						invalidoption=true
						ignore_continue_enter=false	

					;;
				esac
			;;

			htb*)
				echo -e $LIGHTYELLOW"htb"$END")" "Hack The Box"
				echo ""

				if [[ $(ls /etc/hackutils | grep htbExplorer) != "" ]];
				then

					echo -e "What you want to do?"
				
					options_array=("Setup the hacking enviroment" "Connect to HTB VPN" "Download my HTB VPN profile")
					options_selector 3 "options_array"

					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
					echo ""

					## If selection is 0, exit this option
					if [[ $selection == "exit" ]]; then break; fi

					case $selection in
						1)
							echo "Type the name of the machine you want to hack:"
							echo -ne $BLINK" > "$END$LIGHTYELLOW ; read machine ; echo -ne "" $END
							echo ""

							sudo htbExplorer -s $machine
							cd ${directories_array[1]}
							mkdir $machine; cd $machine
							bash /etc/hackutils/htbMkt.sh

							echo -ne "\n\nDirectory created for $CYAN$BOLD$machine$END -->" $CYAN$BOLD; pwd; echo -e $END
							echo -ne "Directory tree created $CYAN$BOLD$machine$END machine: \n"; tree ${directories_array[1]}$machine
							echo ""
							echo ""
					
						;;

						2)
							mv ${configurations_array[0]} ${directories_array[0]} 2> /dev/null
							pid=`ps aux | grep davidahid.ovpn | head -n1 | tr -s [[:space:]] | grep /home/b4shnhawx/.secret/ovpns/ | cut -f2 -d" "`

							if [[ $(ls ${directories_array[0]} | grep ${configurations_array[0]}) == "" ]];
							then
								echo -e $LIGHTRED$BOLD"An error was ocurred while trying to connect to the VPN. I couldn't find the profile ${configurations_array[0]} in the directory ${directories_array[0]}"$END
				
								break

							elif [[ $pid != "" ]];
							then
								echo -e $CYAN$BOLD" > It seems that you are already connected to the HTB VPN. If you think you are not, try killing the existing process ($pid) and try again. If it continues to give problems, re-download your HTB VPN profile."$END
							else					
								echo ""
								echo -ne $CYAN$BOLD" > Connecting to HTB VPN\n"$END
								echo ""
								echo -e "HTB VPN directory: $CYAN$BOLD${directories_array[0]}${configurations_array[0]}"$END
								nohup openvpn ${directories_array[0]}${configurations_array[0]} 2> /dev/null &
								waitFunction "6" "0.10"

								echo -ne $CYAN$BOLD" > When you want to disconnect from the HTB VPN you can use the ovpn) option of Hack_Utils!"$END 
							fi

						;;

						3)
							echo -ne $CYAN$BOLD" > Login in HTB\n"$END
							pkill "openvpn"

							waitFunction "4" "0.10"

							cd /etc/hackutils/

							echo -ne "Email: "
							sudo python /etc/hackutils/htbExplorer/downloadVPN.py ${configurations_array[0]}
		
							if [[ $(ls /etc/hackutils | grep \.ovpn) != ${configurations_array[0]} ]];
							then
								echo -e $LIGHTRED$BOLD"An error was ocurred while trying to download VPN: "
								echo -e "$TAB - Bad email or password" 
								echo -e "$TAB - Bad installation of htbExplorer"
								echo -e "$TAB - Bad configuration in hack_utils.conf"
								echo -e "$TAB - Python request library not installed (apt-get install python-request)"$END
				
								break
							fi
							
						;;

						0)
							ignore_continue_enter=true

							break
						;;

						*)
							invalidoption=true
							ignore_continue_enter=false	

						;;
				esac
				
				else
					mkdir /etc/hackutils/ 2> /dev/null
					cd /etc/hackutils/

					echo -e $LIGHTRED$BOLD"htbExplorer is not installed..."$END
					echo -e $CYAN$BOLD" > Downloading repository from github.com/s4vitar..."$END

					git clone https://github.com/s4vitar/htbExplorer.git 				
					cd htbExplorer	    										
					cp htbExplorer htbExplorer_tmp

					echo ""
					echo "Type your HTB API token:"
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read api ; echo -ne "" $END
					echo ""

					cat htbExplorer_tmp | sed "s|API_TOKEN=""|API_TOKEN='${api}' #|g" > htbExplorer	
					#sudo cp downloadVPN.py /etc/hackutils/ 									    
					#sudo cp htbExplorer /etc/hackutils/ 									   
					sudo cp htbExplorer /usr/bin 									    
					sudo chmod +x /usr/bin/htbExplorer
					
				fi	

			;;

			http*)
				echo -e $LIGHTYELLOW"http"$END")" "Python simple HTTP server"
				echo ""

				echo -e "In which port you want to configure your HTTP server?"
				echo -e "Press "$LIGHTYELLOW"ENTER"$END" to leave by default ("$CYAN$BOLD"8000"$END")."
				echo -ne $BLINK" >  "$END" IP: "$LIGHTYELLOW ; read port ; echo -ne "" $END
				echo ""

				if [[ -z $port ]];
				then
					port="8000"
				else
					port_checker "$port"
				fi

				echo -e $CYAN$BOLD" > Serving "${directories_array[6]}" in "$port$END

				pushd ${directories_array[6]}
				python -m SimpleHTTPServer $port &> /dev/null &
				popd
			;;

			rev*)
				while true;
				do
					clear
	
					echo -e $LIGHTYELLOW"rev"$END")" "Listener for reverse shells connections"
					echo ""
	
					echo -e "What you want to do?"
					
					options_array=("Start new listener" "View one backgrounded listener" "Terminate all enabled reverse shells")
					options_selector 3 "options_array"
	
					echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
					echo ""
	
					## If selection is 0, exit this option
					if [[ $selection == "exit" ]]; then break; fi
	
					case $selection in
						1)		
							echo -e "What interface you want to monitor in conky?"
			
							options_selector $number_of_interfaces "ifaces_array"
			
							echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
							echo ""
			
							response_checker "$selection" "$number_of_interfaces"					
			
							ip_address=`ip addr | grep ${ifaces_array[$selection]} | egrep -o "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/[0-9]{2}" | cut -f1 -d"/"`

							## If selection is 0, exit this option
							if [[ $selection == "exit" ]]; then break; fi

	
							echo "Type the port you want to use for listen:"
							echo -ne $BLINK" > "$END$LIGHTYELLOW ; read port ; echo -ne "" $END
							echo ""
			
							port_checker "$port"
			
							time=0.1

							echo -e $CYAN$BOLD" > Starting new listener in "$RED"$ip_address"":""$port"$END

							waitFunction "3" "0.1"

							ip_address=`echo $ip_address | tr '.' '-'`

							session_name="REV-"$ip_address"_"$port
			
							tmux new-session -d -t $session_name && sleep $time
							#tmux resize-pane -t 1 -L 12 && sleep $time
							tmux select-pane -t 0 && sleep $time
	
							ip_address=`echo $ip_address | tr '-' '.'`

							tmux send-keys "nc -nlvp $port -s $ip_address" C-m && sleep $time
						
						;;
	
						2)
							sessions_extracted=`tmux list-sessions | egrep -o "^REV-(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\-){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])_[0-9]{1,5}-[0-9]{1,2}" | tr '\n' " "`
	
							read -a sessions_array <<< $sessions_extracted 
							
							number_of_sessions=${#sessions_array[@]}
	
							if [[ $number_of_sessions > 0 ]];
							then
								echo "Select the reverse shell:"
								options_selector $number_of_sessions "sessions_array"
	
								echo -ne $BLINK" > "$END$LIGHTYELLOW ; read selection ; echo -ne "" $END
								echo ""
	
								echo -e $CYAN$BOLD" > Remember that if you want to exit but keep the reverse shell in background you must press "$LIGHTYELLOW"Ctrl + b --> d (detached)"$END
								waitFunction "5" "0.20"
	
								tmux attach-session -t ${sessions_array[$selection]}

								if [[ $? == 1 ]]; then echo ""; echo ""; echo -e $LIGHTRED$BOLD"Selected invalid reverse shell"$END; sleep 2; fi
	
							else
								echo -e $LIGHTRED$BOLD"No reverse shell available"$END
	
								break
							fi
						;;
	
						3)
							active_sessions=`tmux list-sessions | egrep "^REV-(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\-){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])_[0-9]{1,5}-[0-9]{1,2}" | cut -f1 -d":"`
			
							for session in $active_sessions:
							do
								echo "Killing reverse shell $session"
								tmux kill-session -t $session && sleep $time
								waitFunction "3" "0.03"
							done
						;;
	
						0)
							ignore_continue_enter=true
	
							break
	
						;;
	
						*)
							invalidoption=true
							ignore_continue_enter=false	
	
						;;
		
					esac
				done
			;;

			0)
				exit

			;;

			*)
				invalidoption=ignore

				#read

				;;
			esac

			break

	done

	#If the user type an invalid option...
	if [[ $ignore_continue_enter == true ]];
	then
		#...do nothing
		:
	
	#...but if the option is included in the case
	elif [[ $invalidoption == false ]];
	then
		#Waits for user to press the enter key after he view what he need
		echo ""
		echo ""
		echo -ne $UNDERGRAY$BLACK"Press ENTER to go back to the main menu"$END$HIDE
		tput civis
		read
		tput cnorm
	
	elif [[ $invalidoption == true ]];
	then
		#Waits for user to press the enter key after he view what he need
		echo ""
		echo ""
		echo -ne $UNDERRED$WHITE"Invalid option... omiting... Press ENTER to go back to the main menu"$END$HIDE
		tput civis
		read
		tput cnorm
	
	elif [[ $invalidoption == error ]];
	then
		tput civis
		read
		tput cnorm
	
	elif [[ $invalidoption == ignore ]];
	then
		:
	
	else
		#Waits for user to press the enter key after he view what he need
		echo ""
		echo ""
		echo -ne $UNDERRED$WHITE"error"$END$HIDE
		tput civis
		read
		tput cnorm
	fi

	invalidoption=false
	ignore_continue_enter=false
	#Set all control variables to default
	#selected_interface=""
	#option=""
done
