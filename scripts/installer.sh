#!/bin/bash

cd
sudo mkdir /etc/hackutils/
sudo touch /etc/hackutils/hack_utils.conf
cat <<EOF > /etc/hackutils/hack_utils.conf
ARRAY
1			OVPN_DIR=$HOME/.secret/ovpns/
2			HTB_DIR=$HOME/HTB/
3			TMP_DIR=/tmp/hackutils
EOF

sudo cp Hack-Utils/scripts/hack_utils.sh /etc/hackutils/
sudo cp Hack-Utils/scripts/bl.sh /etc/hackutils/
sudo cp Hack-Utils/scripts/hackutils /bin/

sudo chmod 700 /bin/hackutils
sudo chmod +x /bin/hackutils

cd
sudo rm -rf Hack-Utils/
