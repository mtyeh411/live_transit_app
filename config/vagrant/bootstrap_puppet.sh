#!/usr/bin/env bash
# Bootstrap Puppet on a Debian/Ubuntu box

echo "Configuring PuppetLabs repo..."
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb 2> /dev/null
sudo dpkg -i puppetlabs-release-precise.deb 2> /dev/null
sudo apt-get -y update 2> /dev/null

echo "Installing Puppet..."
sudo apt-get -y install puppet

echo "Puppet installed!"
