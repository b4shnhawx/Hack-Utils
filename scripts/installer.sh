#!/bin/bash

cd
sudo mkdir /etc/hackutils/
sudo touch /etc/hackutils/hack_utils.conf
cat <<EOF > /etc/hackutils/hack_utils.conf
ARRAY
OVPN_DIR=$HOME/.secret/ovpns/
HTB_DIR=$HOME/HTB/
TMP_DIR=/tmp/hackutils/
CONKY_DIR=$HOME/.config/autostart/
CONKYRC_DIR=$HOME/
SCRIPTS_DIR=$HOME/Scripts/
HTB_OVPN_NAME=YOUR_HTB_NAME.ovpn
EOF

sudo cp Hack-Utils/scripts/hack_utils.sh /etc/hackutils/
sudo cp Hack-Utils/scripts/bl.sh /etc/hackutils/
sudo cp Hack-Utils/scripts/htbMkt.sh /etc/hackutils/
sudo cp Hack-Utils/scripts/dwa.sh /etc/hackutils/
sudo cp -r Hack-Utils/scripts/conky/ /etc/hackutils/
sudo cp Hack-Utils/scripts/hackutils /bin/

sudo chmod 700 /bin/hackutils
sudo chmod +x /bin/hackutils

cd
sudo rm -rf Hack-Utils/
