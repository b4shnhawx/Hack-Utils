#!/bin/bash

cd
mkdir /etc/netutils/
sudo cp $HOME/Deauth-packets-injection/scripts/deauth_wireless_attack.sh /etc//netutils/
sudo cp $HOME/Deauth-packets-injection/scripts/dwa /bin/
sudo chmod u+x /bin/dwa
