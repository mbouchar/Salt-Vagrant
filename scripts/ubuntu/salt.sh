#!/bin/sh

set -e
set -x

wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
sudo su - -c 'echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list'

sudo apt-get install -yq salt-master
sudo apt-get install -yq salt-minion
sudo apt-get install -yq salt-ssh
sudo apt-get install -yq salt-syndic
sudo apt-get install -yq salt-cloud
sudo apt-get install -yq salt-api

sudo su - -c "echo '127.0.0.1 salt' >> /etc/hosts"
sudo systemctl restart salt-minion

sleep 5
sudo salt-key -A -y
