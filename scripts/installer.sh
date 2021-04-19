#!/bin/bash

cd
sudo mkdir /etc/hackutils/
cat <<EOF > $HOME/Hack-Utils/scripts/hack_utils.conf
OVPN_DIR=$HOME/.secret/ovpns/
HTB_DIR=$HOME/HTB/
TMP_DIR=/tmp/hackutils/
CONKY_DIR=$HOME/.config/autostart/
CONKYRC_DIR=$HOME/
SCRIPTS_DIR=$HOME/Scripts/
HTTP_DIR=/var/www/
HTB_OVPN_NAME=YOUR_HTB_NAME.ovpn
EOF
sudo cp Hack-Utils/scripts/hack_utils.conf /etc/hackutils/

sudo cp -r Hack-Utils/scripts/* /etc/hackutils/
sudo cp Hack-Utils/scripts/hackutils /bin/

sudo chmod 700 /bin/hackutils
sudo chmod +x /bin/hackutils

cd
rm -rf Hack-Utils/
cd
