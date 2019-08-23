#!/bin/bash

cd
mkdir /etc/netutils/
sudo cp $HOME/Network-Utils/scripts/network_utils.sh /etc/netutils/
sudo cp $HOME/Network-Utils/scripts/netutils /bin/
sudo chmod u+x /bin/netutils
cd
rm -rf $HOME/Network-Utils/
