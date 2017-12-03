#!/bin/sh

set -e
set -x

wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
sudo su - -c 'echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list'

sudo apt-get install -yq salt-master salt-minion salt-ssh salt-cloud salt-api

sudo su - -c "echo 'master: 127.0.0.1' >> /etc/salt/minion.d/master.conf"
sudo systemctl restart salt-minion

sleep 10
sudo salt-key -A -y
