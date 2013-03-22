#!/bin/bash

# No password for sudo
echo "%sudo ALL = NOPASSWD: ALL" >> /etc/sudoers

# Public SSH key for vagrant user
mkdir /home/vagrant/.ssh
curl -s "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub" -o /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# dotdeb.org
echo "deb http://mirrors.ustc.edu.cn/dotdeb/packages.dotdeb.org `lsb_release -cs` all\ndeb-src http://mirrors.ustc.edu.cn/dotdeb/packages.dotdeb.org `lsb_release -cs` all" | sudo tee /etc/apt/sources.list.d/dotdeb.list
curl --silient http://www.dotdeb.org/dotdeb.gpg | apt-key add -

# Install chef
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
echo "chef chef/chef_server_url string http://127.0.0.1:4000" | debconf-set-selections
apt-get update && apt-get install -y opscode-keyring chef

# Install guest additions on next boot
cp /etc/rc.{local,local.bak} && cp /root/poststrap.sh /etc/rc.local

# Install virtualbox-guest-dkms
echo "deb http://download.virtualbox.org/virtualbox/debian `lsb_release -cs` contrib" | sudo tee /etc/apt/sources.list.d/vbox.list
curl --silent http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc | apt-key add -
apt-get update && apt-get upgrade && apt-get install -y virtualbox-guest-dkms virtualbox-ose-guest-dkms

# Clean up
apt-get -y autoremove
apt-get clean

# Wait for disk
sync
