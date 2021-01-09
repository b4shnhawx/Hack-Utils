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
ssid=$3
passwd=$3
interface_nat=$5
network_ip=`echo $ip_address | rev | cut -f2-4 -d"." | rev`

##---------------- FUNCTIONS ----------------


##---------------- SCRIPT ----------------
#trap programTerminated EXIT

clear

if [[ $interface != "wlan"* ]];
then
	echo -e $RED"Not a valid wlan interface selected"$END

	exit 1
fi

cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bckp
cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bckp

#Start the AP
echo -e $LIGHTGREEN$BOLD"----------------------------------- START AP --------------------------------------"$END

echo "" >> /etc/dnsmasq.conf
echo "interface=$interface" >> /etc/dnsmasq.conf
echo "dhcp-range=$network_ip.2,$network_ip.30,255.255.255.0,12h" >> /etc/dnsmasq.conf
echo "dhcp-option=3,$ip_address" >> /etc/dnsmasq.conf
echo "dhcp-option=6,$ip_address" >> /etc/dnsmasq.conf
echo "server=8.8.8.8" >> /etc/dnsmasq.conf
echo "log-queries" >> /etc/dnsmasq.conf
echo "log-dhcp" >> /etc/dnsmasq.conf
echo "listen-address=127.0.0.1" >> /etc/dnsmasq.conf

echo "interface=$interface" >> /etc/hostapd/hostapd.conf
echo "driver=nl80211" >> /etc/hostapd/hostapd.conf
echo "ssid=$ssid" >> /etc/hostapd/hostapd.conf
echo "hw_mode=g" >> /etc/hostapd/hostapd.conf
echo "channel=8" >> /etc/hostapd/hostapd.conf
echo "macaddr_acl=0" >> /etc/hostapd/hostapd.conf
echo "ignore_broadcast_ssid=0" >> /etc/hostapd/hostapd.conf
echo "auth_algs=1" >> /etc/hostapd/hostapd.conf


if [[ -z $passwd ]];
then
	echo "wpa=2" >> /etc/hostapd/hostapd.conf
	echo "wpa_key_mgmt=WPA-PSK" >> /etc/hostapd/hostapd.conf
	echo "rsn_pairwise=TKIP" >> /etc/hostapd/hostapd.conf
	echo "wpa_passphrase=$passwd" >> /etc/hostapd/hostapd.conf
fi

#Set the APIP IP (like default gateway)
ifconfig $interface $ip_address/24
#Starts the DNS and DHCP server
service dnsmasq restart
#Permits to our device routing the networks
sysctl net.ipv4.ip_forward=1
#Add the route to know how to reach the network
route add -net $network_ip.0 netmask 255.255.255.0 gw $ip_address
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
hostapd /etc/hostapd/hostapd.conf



#Stop the AP: when pressed Ctrl + C
echo -e $LIGHTRED$BOLD"----------------------------------- STOP AP --------------------------------------"$END
#Deletes the firewall rules of the AP.
iptables -D POSTROUTING -t nat -o $interface -j MASQUERADE
iptables -D INPUT ACCEPT
#Disable the routing between interfaces.
sysctl net.ipv4.ip_forward=0
#Stops the DHCP, DNS services and the AP.
service dnsmasq stop
service hostapd stop

cp /etc/dnsmasq.conf.bckp /etc/dnsmasq.conf
cp /etc/hostapd/hostapd.conf.bckp /etc/hostapd/hostapd.conf
