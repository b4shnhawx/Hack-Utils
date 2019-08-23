#!/bin/bash

cd
sudo mkdir /etc/netutils/
sudo cp Network-Utils/scripts/network_utils.sh /etc/netutils/
sudo cp Network-Utils/scripts/netutils /bin/
sudo chmod +x /bin/netutils
cd
sudo rm -rf Network-Utils/
