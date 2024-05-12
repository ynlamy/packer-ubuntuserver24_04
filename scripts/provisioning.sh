#!/bin/bash

# Description : Creating a virtual machine template under Ubuntu Server 24.04 LTS from ISO file with Packer using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/packer-ubuntuserver24_04>
# Licence : GPLv3

echo "Updating the system..."
apt -qq -y update &> /dev/null
apt -qq -y upgrade &> /dev/null

echo "Installing packages..."
apt -qq -y install locate net-tools unzip &> /dev/null

echo "Cleaning apt cache..."
apt -qq -y clean &>/dev/null
