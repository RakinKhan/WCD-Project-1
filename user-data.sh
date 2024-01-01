#! /bin/bash

sudo apt update -y 
sudo apt install python3.10 -y
sudo apt install python3-pip -y
sudo apt install nodejs
sudo apt install npm
nvm install 18.0.0
nvm use 18.0.0
sudo apt install openjdk-11-jdk
sudo apt update -y 
# Install Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce
sudo apt update -y 