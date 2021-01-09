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
interface=$1
ip_address=$2
interface_nat=$3

##---------------- FUNCTIONS ----------------


##---------------- SCRIPT ----------------
#trap programTerminated EXIT

clear


if [[ $interface != "wlan"* ]];
then
	echo -e $RED"Not a valid wlan interface selected"$END

	exit 1
fi

#Start the AP
echo -e $LIGHTGREEN$BOLD"------------------------------- START AP ----------------------------------"$END
#Set the APIP IP (like default gateway)
ifconfig $interface $ip_address/24
#Starts the DNS and DHCP server
service dnsmasq restart
#Permits to our device routing the networks
sysctl net.ipv4.ip_forward=1
#Interface for NATting (translate) the IP's between our wireless interface and the nat interface.
#This allows to all devices connected to our wireless network to get access to internet thanks to
#the nat interface.
iptables -t nat -A POSTROUTING -o $interface_nat -j MASQUERADE
#Permits communication for port 53 (default port for DNS)
iptables -t filter -I INPUT  -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
#Permits all entry communications
iptables -P INPUT ACCEPT
#Sets the AP as the DNS for the wireless network we have created
echo "nameserver $ip_address" >> /etc/resolv.conf
#Initialises the AP.
hostapd /etc/hostapd.conf

tmux detach-client


#Stop the AP: when pressed Ctrl + C
echo -e $LIGHTGREEN$BOLD"------------------------------- STOP AP ----------------------------------"$END
#Deletes the firewall rules of the AP.
iptables -D POSTROUTING -t nat -o $interface -j MASQUERADE
iptables -D INPUT ACCEPT
#Disable the routing between interfaces.
sysctl net.ipv4.ip_forward=0
#Stops the DHCP, DNS services and the AP.
service dnsmasq stop
service hostapd stop
