#!/bin/bash -e

sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 16126D3A3E5C1192
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:ubuntugis/ppa -y
sudo apt-get update -qq
sudo apt-get install libgdal-dev
