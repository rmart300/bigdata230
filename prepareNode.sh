#!/bin/bash

echo "****************************"
echo "Starting Prepare Host"
echo "****************************"



echo -e "\nInstalling Packages"
sudo yum install -y wget ntp

echo -e "\nSetting Umask to 022"
umask 022
echo "umask 022" >> ~/.bashrc
#change this to a sed statement

echo -e "\nSetting ulimit to 65535"
ulimit -n 65535

#disable SELinux
echo -e "\nDisabling SELinux"
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Turn off autostart of iptables and ip6tables
echo -e "\nChecking firewalld is off"
sudo service firewalld stop
sudo chkconfig firewalld off

#Set Swapiness
echo -e "Setting Swapiness to 0"
sudo echo 0 | sudo tee /proc/sys/vm/swappiness
sudo echo vm.swappiness = 0 | sudo tee -a /etc/sysctl.conf

sudo swapoff --all

#Turn on NTPD
echo -e "Setting up NTPD and syncing time"
#Need to add a check to see if NTPD is installed.  If not install it
sudo chkconfig ntpd on
sudo ntpd -q
sudo service ntpd start

#Setup Disks
echo -e "Setting up Disks"
sudo mkfs -t ext4 /dev/xvdb
sudo mkfs -t ext4 /dev/xvdc
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i '$ a/dev/xvdb /data0 ext4 defaults 0 0' 	/etc/fstab
sudo sed -i '$ a/dev/xvdc /data1 ext4 defaults 0 0' 	/etc/fstab