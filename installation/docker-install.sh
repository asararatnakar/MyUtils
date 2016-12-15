#!/bin/bash

   codename=$(lsb_release -c | awk '{print $2}')
   sudo echo "deb https://apt.dockerproject.org/repo ubuntu-${codename} main" >/tmp/docker.list
   sudo cp /tmp/docker.list /etc/apt/sources.list.d/docker.list
   sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
   sudo apt-get update
   sudo apt-get -y upgrade
   sudo apt-get -y install docker-engine
   sudo groupadd docker
   sudo usermod -aG docker $(who are you | awk '{print $1}')

