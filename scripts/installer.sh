#!/bin/bash

cd
sudo mkdir /etc/hackutils/
sudo cp Hack-Utils/scripts/hack_utils.sh /etc/hackutils/
sudo cp Hack-Utils/scripts/bl.sh /etc/netutils/
sudo cp Hack-Utils/scripts/hackutils /bin/

sudo chmod 700 /bin/hackutils
sudo chmod +x /bin/hackutils

cd
sudo rm -rf Hack-Utils/
